-- ══════════════════════════════════════════════════════
--  REMAX Noble — Ficha de Visita  (versão final segura)
--  Cole TUDO abaixo no SQL Editor e clique Run.
-- ══════════════════════════════════════════════════════

-- PASSO 1: Criar tabela mínima (ignora se já existir)
CREATE TABLE IF NOT EXISTS visits (
  id                    UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  created_at            TIMESTAMPTZ DEFAULT NOW(),
  user_id               UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  broker_name           TEXT,
  broker_creci          TEXT,
  broker_phone          TEXT,
  endereco              TEXT,
  proprietario_nome     TEXT,
  proprietario_telefone TEXT,
  tipo_imovel           TEXT,
  valor_pedido          TEXT,
  data_visita           TEXT,
  questionario          JSONB,
  status                TEXT DEFAULT 'pendente',
  total_fotos           INTEGER DEFAULT 0,
  observacoes           TEXT
);

-- PASSO 2: Adicionar colunas faltantes (bloco seguro — ignora erros de coluna duplicada)
DO $$
BEGIN
  BEGIN ALTER TABLE visits ADD COLUMN questionario JSONB;         EXCEPTION WHEN duplicate_column THEN NULL; END;
  BEGIN ALTER TABLE visits ADD COLUMN status TEXT DEFAULT 'pendente'; EXCEPTION WHEN duplicate_column THEN NULL; END;
  BEGIN ALTER TABLE visits ADD COLUMN total_fotos INTEGER DEFAULT 0; EXCEPTION WHEN duplicate_column THEN NULL; END;
  BEGIN ALTER TABLE visits ADD COLUMN observacoes TEXT;           EXCEPTION WHEN duplicate_column THEN NULL; END;
  BEGIN ALTER TABLE visits ADD COLUMN valor_pedido TEXT;          EXCEPTION WHEN duplicate_column THEN NULL; END;
  BEGIN ALTER TABLE visits ADD COLUMN data_visita TEXT;           EXCEPTION WHEN duplicate_column THEN NULL; END;
  BEGIN ALTER TABLE visits ADD COLUMN tipo_imovel TEXT;           EXCEPTION WHEN duplicate_column THEN NULL; END;
END $$;

-- PASSO 3: Ativar segurança por linha
ALTER TABLE visits ENABLE ROW LEVEL SECURITY;

-- PASSO 4: Criar política de acesso
DROP POLICY IF EXISTS "own_visits" ON visits;
CREATE POLICY "own_visits" ON visits
  FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ══════════════════════════════════════════════════════
--  PASSO 5: Tabela de Captação de Imóveis
--  (prospectos do Bairro Dores — sincroniza entre dispositivos)
-- ══════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS captar_prospects (
  id           TEXT PRIMARY KEY,
  user_id      UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  endereco     TEXT,
  proprietario TEXT,
  valor        TEXT,
  tipo         TEXT,
  link         TEXT,
  obs          TEXT,
  lat          NUMERIC,
  lng          NUMERIC,
  status       TEXT DEFAULT 'prospecto',
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE captar_prospects ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "own_prospects" ON captar_prospects;
CREATE POLICY "own_prospects" ON captar_prospects
  FOR ALL
  USING  (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ══════════════════════════════════════════════════════
--  PASSO 6: Novas colunas em captar_prospects
--  (telefones e data de follow-up — adicione se ainda não existirem)
-- ══════════════════════════════════════════════════════

ALTER TABLE captar_prospects ADD COLUMN IF NOT EXISTS telefones    TEXT;
ALTER TABLE captar_prospects ADD COLUMN IF NOT EXISTS followup_date TEXT;

-- ══════════════════════════════════════════════════════
--  Deve aparecer "Success". Depois suba o index.html
--  no GitHub Pages e teste o app no celular.
-- ══════════════════════════════════════════════════════
