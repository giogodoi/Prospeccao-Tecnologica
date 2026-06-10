CREATE USER n8n_user WITH PASSWORD 'n8n_password';
CREATE DATABASE n8n OWNER n8n_user;

CREATE USER ai_user WITH PASSWORD 'ai_password';
CREATE DATABASE ai_memory OWNER ai_user;

CREATE USER evolution_user WITH PASSWORD 'evolution_password';
CREATE DATABASE evolution OWNER evolution_user;
