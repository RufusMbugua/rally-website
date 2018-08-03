#!/bin/sh

php artisan voyager:install
exec apache2-foreground