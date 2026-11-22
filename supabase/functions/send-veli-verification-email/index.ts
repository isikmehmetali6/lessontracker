// Veli onayı doğrulama e-postası (eski Firebase `sendVeliVerificationEmail`).
//
// Secrets: EMAIL_USER, EMAIL_PASS (Gmail uygulama şifresi), EMAIL_FROM (opsiyonel)
//   supabase secrets set EMAIL_USER=... EMAIL_PASS=... EMAIL_FROM="LessonTracker <noreply@...>"
import nodemailer from "npm:nodemailer@6.9.16";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// Instance başına bellek içi limit (eski Cloud Function ile aynı davranış).
const WINDOW_MS = 5 * 60 * 1000;
const MAX_REQUESTS = 3;
const rateLimitMap = new Map<string, { count: number; resetTime: number }>();

function checkRateLimit(email: string) {
  const now = Date.now();
  for (const [key, record] of rateLimitMap) {
    if (now > record.resetTime) rateLimitMap.delete(key);
  }
  const record = rateLimitMap.get(email);
  if (!record) {
    rateLimitMap.set(email, { count: 1, resetTime: now + WINDOW_MS });
    return { allowed: true, remaining: MAX_REQUESTS - 1, cooldown: 0 };
  }
  if (record.count >= MAX_REQUESTS) {
    return {
      allowed: false,
      remaining: 0,
      cooldown: Math.ceil((record.resetTime - now) / 1000),
    };
  }
  record.count++;
  return { allowed: true, remaining: MAX_REQUESTS - record.count, cooldown: 0 };
}

function escapeHtml(value: string) {
  return value.replace(/[&<>"']/g, (c) => `&#${c.charCodeAt(0)};`);
}

function buildHtml(code: string, veliName: string) {
  return `<!DOCTYPE html>
<html>
<head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>Veli Onayı - Doğrulama Kodu</title></head>
<body style="margin:0;padding:0;font-family:'Segoe UI',Tahoma,Geneva,Verdana,sans-serif;background-color:#f4f4f4;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color:#f4f4f4;padding:40px 20px;">
    <tr><td align="center">
      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width:600px;background-color:#ffffff;border-radius:16px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.1);">
        <tr><td style="background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);padding:40px 30px;text-align:center;">
          <h1 style="color:#ffffff;margin:0;font-size:28px;font-weight:600;">LessonTracker</h1>
          <p style="color:rgba(255,255,255,0.9);margin:10px 0 0 0;font-size:16px;">Veli Onayı Sistemi</p>
        </td></tr>
        <tr><td style="padding:40px 30px;">
          <p style="color:#333333;font-size:18px;margin:0 0 20px 0;">Merhaba ${escapeHtml(veliName)},</p>
          <p style="color:#666666;font-size:16px;line-height:1.6;margin:0 0 30px 0;">Çocuğunuzun ders takibi için veli onayı gerekiyor. Aşağıdaki 6 haneli doğrulama kodunu kullanarak onay işlemini tamamlayabilirsiniz.</p>
          <div style="background-color:#f8f9fa;border:2px dashed #dee2e6;border-radius:12px;padding:30px;text-align:center;margin:0 0 30px 0;">
            <p style="color:#888888;font-size:14px;margin:0 0 10px 0;text-transform:uppercase;letter-spacing:1px;">Doğrulama Kodunuz</p>
            <p style="color:#1a1a1a;font-size:42px;font-weight:700;margin:0;letter-spacing:8px;font-family:'Courier New',monospace;">${code}</p>
          </div>
          <div style="background-color:#e8f4fd;border-left:4px solid #2196F3;border-radius:8px;padding:20px;margin:0 0 30px 0;">
            <p style="color:#1565C0;font-size:14px;margin:0;line-height:1.6;"><strong>⏱️ Geçerlilik Süresi:</strong> Bu kod 30 dakika içinde kullanılmalıdır.<br><strong>🔒 Güvenlik:</strong> Bu kodu kimseyle paylaşmayın.</p>
          </div>
          <p style="color:#888888;font-size:14px;line-height:1.6;margin:0;">Eğer bu talebi siz yapmadıysanız, bu emaili görmezden gelebilirsiniz.</p>
        </td></tr>
        <tr><td style="background-color:#f8f9fa;padding:20px 30px;text-align:center;border-top:1px solid #eeeeee;">
          <p style="color:#888888;font-size:12px;margin:0;">LessonTracker © ${new Date().getFullYear()} | Bu email otomatik olarak gönderilmiştir</p>
        </td></tr>
      </table>
    </td></tr>
  </table>
</body>
</html>`;
}

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  let payload: { email?: string; code?: string; veliName?: string };
  try {
    payload = await req.json();
  } catch {
    return json({ error: "Invalid JSON body" }, 400);
  }
  const { email, code, veliName } = payload;

  if (!email || !code) return json({ error: "Email and code are required" }, 400);
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    return json({ error: "Invalid email format" }, 400);
  }
  if (!/^\d{6}$/.test(code)) return json({ error: "Code must be 6 digits" }, 400);

  const rateLimit = checkRateLimit(email);
  if (!rateLimit.allowed) {
    return json(
      { error: `Çok fazla istek. Lütfen ${rateLimit.cooldown} saniye bekleyin.` },
      429,
    );
  }

  try {
    const transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: Deno.env.get("EMAIL_USER"),
        pass: Deno.env.get("EMAIL_PASS"),
      },
    });
    await transporter.sendMail({
      from: Deno.env.get("EMAIL_FROM") ?? "LessonTracker <noreply@lessontracker.com>",
      to: email,
      subject: "Veli Onayı - Doğrulama Kodu",
      html: buildHtml(code, veliName || "Veli"),
    });
    return json({
      success: true,
      message: "Doğrulama emaili gönderildi",
      remainingRequests: rateLimit.remaining,
    });
  } catch (error) {
    console.error("Email send error:", error);
    return json({ error: "Email gönderilemedi" }, 500);
  }
});
