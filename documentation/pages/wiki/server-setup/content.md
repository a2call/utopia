# Server Setup

The best deployment platform for Utopia is Linux. Specifically, [Arch Linux](https://www.archlinux.org/) with the following packages:

- [nginx-mainline-passenger](https://aur.archlinux.org/packages/nginx-mainline-passenger/)
- [passenger-nginx-module](https://aur.archlinux.org/packages/passenger-nginx-module/)

There have been issues with the official packages and thus these packages were developed and tested with Utopia deployment in mind.

## Sample Nginx Configuration

Create a configuration file for your site, e.g. `/etc/nginx/sites/www.example.com`:

	server {
		listen 80;
		server_name www.example.com;
		root /srv/http/www.example.com/public;
		passenger_enabled on;
	}

	server {
		listen 80;
		server_name example.com;
		rewrite ^ http://www.example.com$uri permanent;
	}

## Deployment via Git

The preferred method of deployment to a production server is via git. The `utopia` command assists with setup of a remote git repository on the server. It will setup a `git` `post-update` hook which will deploy the site correctly and restart passenger for that site.

To setup a server for deployment:

	$ mkdir /srv/http/www.example.com
	$ cd /srv/http/www.example.com
	$ sudo -u http utopia server create

On your development machine, you should setup the git remote:

	$ git remote add production ssh://remote/srv/http/www.example.com
	$ git push --set-upstream production master
