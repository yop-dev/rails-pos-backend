# Render Deployment Guide - Rails POS Backend with Maileroo

## 🚀 Quick Deployment Checklist

### Prerequisites
- [x] GitHub repository with your code
- [x] Maileroo account with credentials configured
- [x] Cloudinary account configured
- [ ] Render account (free tier is fine)

### Step 1: Create PostgreSQL Database
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click **"New"** → **"PostgreSQL"**
3. **Name**: `rails-pos-db` (or any name you prefer)
4. **Database**: `rails_pos_production`
5. **User**: Leave default
6. **Region**: Choose closest to you
7. **Plan**: **Free** (sufficient for testing)
8. Click **"Create Database"**
9. ⚠️ **Save the connection details** (you'll need them)

### Step 2: Create Web Service
1. In Render Dashboard, click **"New"** → **"Web Service"**
2. **Connect your GitHub repository**
3. **Repository**: Select your `rails-pos` repository
4. **Name**: `rails-pos-backend`
5. **Root Directory**: `rails-pos-backend`
6. **Environment**: `Ruby`
7. **Region**: Same as your database
8. **Branch**: `main` (or your default branch)
9. **Build Command**: 
   ```bash
   bundle install
   ```
10. **Start Command**:
    ```bash
    bundle exec rails server -p $PORT -b 0.0.0.0
    ```
11. **Plan**: **Free** (sufficient for testing)

### Step 3: Configure Environment Variables

In your web service settings, go to **Environment** and add these variables:

#### Required Rails Variables
```bash
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
SECRET_KEY_BASE=YOUR_SECRET_KEY_HERE
```

To generate SECRET_KEY_BASE, run locally:
```bash
rails secret
```

#### Database (Link Database Instead)
Instead of manually setting DATABASE_URL:
1. Go to your web service **Settings**
2. Scroll to **Environment Variables** 
3. Click **"Link Database"**
4. Select your PostgreSQL database
5. This automatically sets `DATABASE_URL`

#### Maileroo Email Configuration
```bash
MAILEROO_API_KEY=be625c2e8b5016c5e52808b55306b2e8d315ece4842722918140b35930d0a538
MAILEROO_SMTP_EMAIL=rails-pos@railspos.maileroo.app
MAILEROO_SMTP_PASSWORD=4462f8ce1672ec1413f606bc
MAILEROO_FROM_EMAIL=rails-pos@railspos.maileroo.app
MAILEROO_FROM_NAME=Rails POS
```

#### Cloudinary Configuration
```bash
CLOUDINARY_URL=cloudinary://178777925628529:sbz_OE2bDzbgnuhv-nkEth6_mwc@dtzkdk8fr
```

#### App Configuration
```bash
APP_HOST=your-app-name.onrender.com
```
⚠️ **Replace `your-app-name`** with your actual Render service name

### Step 4: Add Post-Deploy Command
1. In your web service settings
2. Scroll to **Build & Deploy**
3. Set **Post-Deploy Command**:
   ```bash
   bundle exec rails db:migrate
   ```

### Step 5: Deploy
1. Click **"Create Web Service"**
2. Render will automatically start building and deploying
3. Watch the build logs for any errors
4. Wait for deployment to complete (usually 3-5 minutes)

### Step 6: Test Your Deployment

Once deployed, your app will be available at:
```
https://your-app-name.onrender.com
```

#### Test GraphQL Endpoint
```
https://your-app-name.onrender.com/graphql
```

#### Test Email Functionality
You can test emails by:
1. Using GraphQL to create an order
2. Checking if confirmation emails are sent
3. Looking at Render logs for email delivery status

## 📧 Environment Variables Summary

Copy and paste these into Render (replace APP_HOST with your actual URL):

```bash
RAILS_ENV=production
RAILS_LOG_TO_STDOUT=true
RAILS_SERVE_STATIC_FILES=true
SECRET_KEY_BASE=YOUR_SECRET_KEY_FROM_RAILS_SECRET_COMMAND
MAILEROO_API_KEY=be625c2e8b5016c5e52808b55306b2e8d315ece4842722918140b35930d0a538
MAILEROO_SMTP_EMAIL=rails-pos@railspos.maileroo.app
MAILEROO_SMTP_PASSWORD=4462f8ce1672ec1413f606bc
MAILEROO_FROM_EMAIL=rails-pos@railspos.maileroo.app
MAILEROO_FROM_NAME=Rails POS
CLOUDINARY_URL=cloudinary://178777925628529:sbz_OE2bDzbgnuhv-nkEth6_mwc@dtzkdk8fr
APP_HOST=your-app-name.onrender.com
```

## 🔧 Troubleshooting

### Build Fails
- Check build logs in Render dashboard
- Ensure all dependencies are in Gemfile
- Make sure Ruby version matches

### Database Connection Issues
- Verify database is linked to web service
- Check DATABASE_URL is automatically set
- Ensure post-deploy command runs migrations

### Email Issues
- Check Render logs for email errors
- Verify Maileroo credentials are correct
- Test email delivery in production

### 500 Errors
- Check application logs in Render dashboard
- Verify all environment variables are set
- Ensure SECRET_KEY_BASE is generated and set

## 🎯 Post-Deployment Testing

1. **GraphQL Endpoint**: Visit `/graphql` and ensure GraphiQL loads
2. **Create Test Data**: Use GraphQL to create merchants, categories, products
3. **Test Orders**: Create an order and verify email is sent
4. **Check Logs**: Monitor Render logs for any errors

## ✅ Success Indicators

- ✅ Service shows "Live" status in Render
- ✅ GraphQL endpoint responds
- ✅ Database migrations complete successfully
- ✅ Email delivery works (check both sent emails and logs)
- ✅ Cloudinary image uploads work

## 🚀 Next Steps After Deployment

1. Update your frontend to use the new Render API URL
2. Set up custom domain (optional)
3. Monitor application performance
4. Set up error monitoring if needed

---

**Need help?** Check Render logs first, then review environment variables setup!