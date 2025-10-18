FROM node:18-alpine

WORKDIR /app

RUN npm init -y && npm install express aws-sdk

COPY proxy.js .

EXPOSE 3000

CMD ["node", "proxy.js"]
