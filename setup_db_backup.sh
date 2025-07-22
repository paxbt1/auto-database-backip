#!/bin/bash

# === 1. تنظیمات کاربر ===
DB_NAME="carloan"                # ← نام دیتابیس
DB_USER="your_db_user"           # ← نام کاربری دیتابیس (MySQL)
DB_PASS="your_db_password"       # ← رمز عبور کاربر دیتابیس
BACKUP_DIR="/var/backups/db"     # ← مسیر نگهداری بکاپ‌ها
SCRIPT_PATH="/opt/backup_db.sh"  # ← محل اسکریپت بکاپ
CRON_JOB="0 3 * * * $SCRIPT_PATH"

# === 2. ساخت پوشه بکاپ ===
echo "📁 در حال ساخت مسیر بکاپ..."
mkdir -p $BACKUP_DIR
chmod 700 $BACKUP_DIR

# === 3. ایجاد اسکریپت بکاپ ===
echo "🛠️ ایجاد اسکریپت بکاپ در $SCRIPT_PATH..."

cat <<EOF > $SCRIPT_PATH
#!/bin/bash

DATE=\$(date +%F)
mysqldump -u $DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/\${DB_NAME}_\${DATE}.sql
find $BACKUP_DIR -type f -name "\${DB_NAME}_*.sql" -mtime +7 -exec rm {} \;
EOF

# === 4. اعمال سطح دسترسی مناسب ===
chmod 700 $SCRIPT_PATH
chown root:root $SCRIPT_PATH

# === 5. بررسی وجود کرون جاب (و افزودن در صورت نبود) ===
echo "🕒 تنظیم کرون‌جاب روزانه ساعت 3 بامداد..."
(crontab -l 2>/dev/null | grep -Fv "$SCRIPT_PATH" ; echo "$CRON_JOB") | crontab -

# === 6. پایان ===
echo "✅ اسکریپت بکاپ دیتابیس با موفقیت نصب شد!"
echo "📦 بکاپ‌ها در مسیر: $BACKUP_DIR"
echo "📅 هر روز ساعت 03:00 بکاپ‌گیری انجام می‌شود و بکاپ‌های قدیمی‌تر از 7 روز حذف خواهند شد."
