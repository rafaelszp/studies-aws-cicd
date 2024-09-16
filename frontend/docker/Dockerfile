FROM public.ecr.aws/nginx/nginx:stable-perl
COPY frontend/nginx/default.conf.template /etc/nginx/templates/default.conf.template
COPY frontend/dist /usr/share/nginx/html/