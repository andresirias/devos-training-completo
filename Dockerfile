#--------------------------------------------
# Stage 2: Build the app
# La informacion generada en este stage sera
# desechada para reducir el tamaño del contendor
# final
#--------------------------------------------
FROM node:14-alpine as build

WORKDIR /app

COPY package*.json ./

RUN npm i --no-package-lock

# Bundle app source
COPY . .

RUN npm run build
#--------------------------------------------
# Stage 2: Serve the app
#--------------------------------------------

FROM node:14-alpine

WORKDIR /app

RUN npm -g install serve

COPY --from=build /app/build ./build/scodex

EXPOSE 3000
# serve on port 3000
CMD ["serve", "-l", "3000", "build"]