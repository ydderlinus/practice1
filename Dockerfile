# Stage 1: Build the web application
FROM node:16-alpine AS webapp-builder
WORKDIR /webapp
COPY simple-webapp .
# For a more complex web app, you might have build steps here (e.g., npm build)

# Stage 2: Serve the web application with Nginx
FROM nginx:alpine
COPY --from=webapp-builder /webapp /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80

# Stage 3: Python server
FROM python:3.9-slim-buster AS python-server
WORKDIR /app
COPY python-server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY python-server .
EXPOSE 5000
CMD ["python", "app.py"]

# Final Stage: Combine both
FROM alpine
RUN apk add --no-cache --update nginx python3 py3-pip
COPY --from=python-server /app /python-app
COPY --from=webapp-builder /usr/share/nginx/html /web-static
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
EXPOSE 5000

CMD ["nginx", "-g", "daemon off;"] & python3 /python-app/app.py

