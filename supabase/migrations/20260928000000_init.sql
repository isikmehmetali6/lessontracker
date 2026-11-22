-- LessonTracker — Supabase başlangıç şeması
-- Firebase (Auth + Firestore + Storage) yerine geçer.

-- ---------------------------------------------------------------------------
-- Profiller (eski Firestore `users/{uid}` belgesi)
-- ---------------------------------------------------------------------------
create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  name        text,
  email       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz,
  last_login  timestamptz
);

alter table public.profiles enable row level security;

create policy "profiles_select_own" on public.profiles
  for select to authenticated using ((select auth.uid()) = id);
create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id) with check ((select auth.uid()) = id);

-- Kayıt olunca profil satırını otomatik oluştur (signUp `data.name` → name)
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, name, email)
  values (new.id, new.raw_user_meta_data ->> 'name', new.email);
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Kullanıcı kayıtları (eski Firestore `users/{uid}/{collection}/{id}`)
--
-- collection: courses | notes | deadlines | grades | files | absences |
--             planner_events | uploads | system
-- data:       istemcide şifrelenmiş içerik ({"encryptedData": "..."}) veya
--             system/uploads için meta veri
-- course_id:  ders silinince ilişkili kayıtları bulmak için düz metin
-- ---------------------------------------------------------------------------
create table public.user_records (
  user_id     uuid not null default auth.uid()
              references auth.users (id) on delete cascade,
  collection  text not null,
  id          text not null,
  course_id   text,
  data        jsonb not null,
  updated_at  timestamptz not null default now(),
  primary key (user_id, collection, id)
);

create index user_records_course_idx
  on public.user_records (user_id, collection, course_id);

alter table public.user_records enable row level security;

create policy "user_records_select_own" on public.user_records
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "user_records_insert_own" on public.user_records
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "user_records_update_own" on public.user_records
  for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "user_records_delete_own" on public.user_records
  for delete to authenticated using ((select auth.uid()) = user_id);

-- ---------------------------------------------------------------------------
-- Hesap silme (KVKK md. 7) — istemci auth.users'ı doğrudan silemez
-- ---------------------------------------------------------------------------
create function public.delete_current_user()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;
  delete from auth.users where id = auth.uid();
end;
$$;

revoke execute on function public.delete_current_user() from public, anon;
grant execute on function public.delete_current_user() to authenticated;

-- ---------------------------------------------------------------------------
-- Storage: şifreli dosyalar — yol biçimi `{uid}/{photos|audio|documents}/...`
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('user-files', 'user-files', false)
on conflict (id) do nothing;

create policy "user_files_select_own" on storage.objects
  for select to authenticated
  using (bucket_id = 'user-files'
         and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "user_files_insert_own" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'user-files'
              and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "user_files_update_own" on storage.objects
  for update to authenticated
  using (bucket_id = 'user-files'
         and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "user_files_delete_own" on storage.objects
  for delete to authenticated
  using (bucket_id = 'user-files'
         and (storage.foldername(name))[1] = (select auth.uid())::text);
