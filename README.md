# E-Shop Rails 7 Application

A modern e-commerce application built with Ruby on Rails 7, PostgreSQL, and Stripe integration.

## System Requirements

* Ruby 3.2.0+
* Rails 7.0.0+
* Sqlite3 14+
* Stripe account for payment processing

## Installation

1. Clone the repository
```bash
git clone https://github.com/kvi1312/E-shop.git
cd e-shop
```

2. Install dependencies
```bash
bundle install
```

3. Database setup
```bash
rails db:create
rails db:migrate
```

4. Configure environment variables and credentials

   This application uses Rails credentials to securely store sensitive information. Set up your Stripe API keys by running:

   ```bash
   EDITOR="code --wait" rails credentials:edit
   ```

   This will open your credentials file in VS Code. Add the following information:

   ```yaml
   stripe:
     publishable_key: your_stripe_publishable_key
     secret_key: your_stripe_secret_key
   
   postgres:
     username: your_db_username
     password: your_db_password
   ```

   Save and close the file.

5. Set up initial data by running the seeds
```bash
rails db:seed
```

## Default Admin User

After seeding the database, you can log in with the following admin credentials:

* Email: lenguyenkhai2611@gmail.com
* Password: 123456

## Running the Application

Start the Rails server:
```bash
rails server
```

Start the JavaScript bundler in a separate terminal:
```bash
yarn build --watch
```

Visit `http://localhost:3000` in your browser.

## Features

* User authentication with Devise
* Product catalog with categories
* Shopping cart functionality
* Secure payment processing with Stripe
* Admin dashboard for managing products, orders, and users
* Responsive design

## Testing

Run the test suite with:
```bash
rails test
```

## Deployment

This application can be deployed to platforms such as Heroku, Render, or Fly.io.

Remember to set up your production credentials separately:
```bash
EDITOR="code --wait" rails credentials:edit --environment production
```

## Troubleshooting

### Database Connection Issues

If you encounter Sqlite3 connection errors:
1. Check your database configuration in `config/database.yml`
2. Ensure Sqlite3 service is running
3. Verify your database credentials

### Stripe Integration

If Stripe payments aren't working:
1. Confirm your Stripe API keys are correctly set in credentials
2. Check Stripe dashboard for webhook events and logs
3. Set your webhook endpoint in the Stripe dashboard

## License

This project is licensed under the MIT License - see the LICENSE file for details.