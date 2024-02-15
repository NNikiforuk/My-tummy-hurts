#Select the base image to start with
FROM node:14-alpine3.12

#Create app directory
#Where I will be inside the container
WORKDIR /usr/src/app

#Install app dependencies
COPY ./server/package*.json ./server/
RUN npm install

#Bundle app source
COPY . .

#Making this port accesible from outside the container
EXPOSE 8080

#Command to run when the container is ready
#Separate arguments as separate values in the array
CMD ["npm", "run", "start"]

