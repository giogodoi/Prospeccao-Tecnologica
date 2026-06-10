\connect ai_memory;

CREATE TABLE IF NOT EXISTS public.customer_memory (
    id BIGSERIAL PRIMARY KEY,
    telefone VARCHAR(30) NOT NULL UNIQUE,
    nome VARCHAR(120),
    ultimo_pedido VARCHAR(30) CHECK (ultimo_pedido IN ('X-Salada', 'X-Bacon', 'X-Burguer')),
    data_ultimo_pedido TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);
