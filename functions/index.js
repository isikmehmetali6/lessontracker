const functions = require('firebase-functions');
const nodemailer = require('nodemailer');

const rateLimitMap = new Map();

function checkRateLimit(email) {
  const now = Date.now();
  const windowMs = 5 * 60 * 1000;
  const maxRequests = 3;
  
  if (!rateLimitMap.has(email)) {
    rateLimitMap.set(email, { count: 1, resetTime: now + windowMs });
    return { allowed: true, remaining: maxRequests - 1 };
  }
  
  const record = rateLimitMap.get(email);
  
  if (now > record.resetTime) {
    rateLimitMap.set(email, { count: 1, resetTime: now + windowMs });
    return { allowed: true, remaining: maxRequests - 1 };
  }
  
  if (record.count >= maxRequests) {
    return { allowed: false, remaining: 0, cooldown: Math.ceil((record.resetTime - now) / 1000) };
  }
  
  record.count++;
  return { allowed: true, remaining: maxRequests - record.count };
}

async function sendVerificationEmail(email, code, veliName) {
  const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
      user: process.env.EMAIL_USER,
      pass: process.env.EMAIL_PASS,
    },
  });

  const htmlContent = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Veli Onayı - Doğrulama Kodu</title>
</head>
<body style="margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f4f4;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background-color: #f4f4f4; padding: 40px 20px;">
    <tr>
      <td align="center">
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width: 600px; background-color: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.1);">
          <!-- Header -->
          <tr>
            <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 30px; text-align: center;">
              <h1 style="color: #ffffff; margin: 0; font-size: 28px; font-weight: 600;">LessonTracker</h1>
              <p style="color: rgba(255,255,255,0.9); margin: 10px 0 0 0; font-size: 16px;">Veli Onayı Sistemi</p>
            </td>
          </tr>
          
          <!-- Content -->
          <tr>
            <td style="padding: 40px 30px;">
              <p style="color: #333333; font-size: 18px; margin: 0 0 20px 0;">Merhaba ${veliName || 'Veli'},</p>
              
              <p style="color: #666666; font-size: 16px; line-height: 1.6; margin: 0 0 30px 0;">
                Çocuğunuzun ders takibi için veli onayı gerekiyor. Aşağıdaki 6 haneli doğrulama kodunu kullanarak onay işlemini tamamlayabilirsiniz.
              </p>
              
              <!-- Code Box -->
              <div style="background-color: #f8f9fa; border: 2px dashed #dee2e6; border-radius: 12px; padding: 30px; text-align: center; margin: 0 0 30px 0;">
                <p style="color: #888888; font-size: 14px; margin: 0 0 10px 0; text-transform: uppercase; letter-spacing: 1px;">Doğrulama Kodunuz</p>
                <p style="color: #1a1a1a; font-size: 42px; font-weight: 700; margin: 0; letter-spacing: 8px; font-family: 'Courier New', monospace;">${code}</p>
              </div>
              
              <!-- Info Box -->
              <div style="background-color: #e8f4fd; border-left: 4px solid #2196F3; border-radius: 8px; padding: 20px; margin: 0 0 30px 0;">
                <p style="color: #1565C0; font-size: 14px; margin: 0; line-height: 1.6;">
                  <strong>⏱️ Geçerlilik Süresi:</strong> Bu kod 30 dakika içinde kullanılmalıdır.<br>
                  <strong>🔒 Güvenlik:</strong> Bu kodu kimseyle paylaşmayın.
                </p>
              </div>
              
              <p style="color: #888888; font-size: 14px; line-height: 1.6; margin: 0;">
                Eğer bu talebi siz yapmadıysanız, bu emaili görmezden gelebilirsiniz.
              </p>
            </td>
          </tr>
          
          <!-- Footer -->
          <tr>
            <td style="background-color: #f8f9fa; padding: 20px 30px; text-align: center; border-top: 1px solid #eeeeee;">
              <p style="color: #888888; font-size: 12px; margin: 0;">
                LessonTracker © 2024 | Bu email otomatik olarak gönderilmiştir
              </p>
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>
`;

  const mailOptions = {
    from: process.env.EMAIL_FROM || 'LessonTracker <noreply@lessontracker.com>',
    to: email,
    subject: 'Veli Onayı - Doğrulama Kodu',
    html: htmlContent,
  };

  return transporter.sendMail(mailOptions);
}

exports.sendVeliVerificationEmail = functions.https.onCall(async (data, context) => {
  const { email, code, veliName } = data;

  if (!email || !code) {
    throw new functions.https.HttpsError('invalid-argument', 'Email and code are required');
  }

  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    throw new functions.https.HttpsError('invalid-argument', 'Invalid email format');
  }

  if (code.length !== 6 || !/^\d+$/.test(code)) {
    throw new functions.https.HttpsError('invalid-argument', 'Code must be 6 digits');
  }

  const rateLimit = checkRateLimit(email);
  if (!rateLimit.allowed) {
    throw new functions.https.HttpsError('resource-exhausted', 
      `Çok fazla istek. Lütfen ${rateLimit.cooldown} saniye bekleyin.`);
  }

  try {
    await sendVerificationEmail(email, code, veliName);
    
    return { 
      success: true, 
      message: 'Doğrulama emaili gönderildi',
      remainingRequests: rateLimit.remaining 
    };
  } catch (error) {
    console.error('Email send error:', error);
    throw new functions.https.HttpsError('internal', 'Email gönderilemedi');
  }
});

exports.cleanupRateLimitMap = functions.pubsub.schedule('every 10 minutes').onRun(() => {
  const now = Date.now();
  for (const [email, record] of rateLimitMap.entries()) {
    if (now > record.resetTime) {
      rateLimitMap.delete(email);
    }
  }
  return null;
});