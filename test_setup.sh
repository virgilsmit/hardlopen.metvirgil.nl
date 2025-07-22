#!/bin/bash

echo "🚀 Start test setup en uitvoering..."

echo "🗄️ Reset test database..."
RAILS_ENV=test bundle exec rails db:drop db:create db:migrate

echo "✅ Database reset voltooid!"

echo "🧪 Draai attendances controller tests..."
RAILS_ENV=test bundle exec rails test test/controllers/attendances_controller_test.rb

echo "🎉 Test uitvoering voltooid!" 