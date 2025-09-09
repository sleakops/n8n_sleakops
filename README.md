This repository is used for deploying n8n on a server using Docker.
For more information, please visit the [n8n documentation](https://docs.n8n.io/getting-started/installation/docker/).
The official n8n Docker image can be found [here](https://hub.docker.com/r/n8nio/n8n).


# 🛠 Install on localhost with docker

## Prerequisites

Ensure you have the following installed on your machine:

- **Docker**: [Download Docker](https://docs.docker.com/get-docker/)
- **Docker Compose**: [Download Docker Compose](https://docs.docker.com/compose/install/)

---

## Setup and Running the Project


#### 1. Generate the `.env` file to configure the environment variables

To set up the environment variables, create a `.env` file based on the provided example:

```bash
cp .env.example .env
```


### 2. Start the Project

Run the following command to start the frontend:

```bash
docker-compose up
```

Once the containers are running, the project will be available at:

[http://localhost:5678](http://localhost:5678)

---