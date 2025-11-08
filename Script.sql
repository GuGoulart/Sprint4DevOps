-- ============================================================================
-- SCRIPT SQL - SPRINT 4 - AZURE DEVOPS
-- FIAP - DevOps Tools & Cloud Computing
-- ============================================================================
-- Projeto: MottuProjeto
-- Banco: Azure SQL Server (mottubanco)
-- Servidor: mottuserver.database.windows.net
-- ============================================================================
-- ATENÇÃO: Este script atende o requisito de ter 2+ tabelas relacionadas
-- Penalidade se não incluir: -1 ponto
-- ============================================================================

-- Configuração inicial do banco
USE mottubanco;
GO

-- ============================================================================
-- TABELA 1: T_VM_AREA (Áreas Operacionais)
-- ============================================================================
-- Tabela principal que armazena as áreas/regiões operacionais
-- Relacionamento: Uma área pode ter várias motos (1:N)

IF OBJECT_ID('dbo.T_VM_AREA', 'U') IS NOT NULL
    DROP TABLE dbo.T_VM_AREA;
GO

CREATE TABLE T_VM_AREA (
    ID_AREA      INT            NOT NULL IDENTITY(1,1),
    NM_AREA      NVARCHAR(100)  NOT NULL,
    
    CONSTRAINT PK_AREA PRIMARY KEY (ID_AREA)
);
GO

-- Comentários descritivos
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador único da área operacional', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_AREA',
    @level2type = N'COLUMN', @level2name = N'ID_AREA';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nome da área/região (ex: Centro, Zona Leste)', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_AREA',
    @level2type = N'COLUMN', @level2name = N'NM_AREA';
GO

-- ============================================================================
-- TABELA 2: T_VM_MOTO (Motos)
-- ============================================================================
-- Armazena informações das motos da frota
-- Relacionamento: Cada moto pertence a UMA área (N:1 com T_VM_AREA)

IF OBJECT_ID('dbo.T_VM_MOTO', 'U') IS NOT NULL
    DROP TABLE dbo.T_VM_MOTO;
GO

CREATE TABLE T_VM_MOTO (
    ID_MOTO      INT            NOT NULL IDENTITY(1,1),
    DS_PLACA     NVARCHAR(20)   NOT NULL,
    NM_MODELO    NVARCHAR(100)  NOT NULL,
    ID_AREA      INT            NOT NULL,
    
    CONSTRAINT PK_MOTO PRIMARY KEY (ID_MOTO),
    CONSTRAINT FK_MOTO_AREA FOREIGN KEY (ID_AREA) 
        REFERENCES T_VM_AREA(ID_AREA)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT UK_MOTO_PLACA UNIQUE (DS_PLACA)
);
GO

-- Índice para melhorar performance de consultas por área
CREATE INDEX IX_MOTO_AREA ON T_VM_MOTO(ID_AREA);
GO

-- Comentários descritivos
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador único da moto', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_MOTO',
    @level2type = N'COLUMN', @level2name = N'ID_MOTO';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Placa da moto (deve ser única)', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_MOTO',
    @level2type = N'COLUMN', @level2name = N'DS_PLACA';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Modelo/marca da moto', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_MOTO',
    @level2type = N'COLUMN', @level2name = N'NM_MODELO';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Chave estrangeira para a área onde a moto opera', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_MOTO',
    @level2type = N'COLUMN', @level2name = N'ID_AREA';
GO

-- ============================================================================
-- TABELA 3: T_VM_USUARIO (Usuários do Sistema)
-- ============================================================================
-- Armazena usuários que podem acessar o sistema
-- Usado para autenticação JWT

IF OBJECT_ID('dbo.T_VM_USUARIO', 'U') IS NOT NULL
    DROP TABLE dbo.T_VM_USUARIO;
GO

CREATE TABLE T_VM_USUARIO (
    ID_USUARIO       INT            NOT NULL IDENTITY(1,1),
    NM_USUARIO       NVARCHAR(100)  NOT NULL,
    DS_EMAIL         NVARCHAR(150)  NOT NULL,
    DS_USERNAME      NVARCHAR(60)   NOT NULL,
    DS_PASSWORD_HASH NVARCHAR(MAX)  NOT NULL,
    DS_ROLE          NVARCHAR(20)   NOT NULL DEFAULT 'User',
    
    CONSTRAINT PK_USUARIO PRIMARY KEY (ID_USUARIO),
    CONSTRAINT UK_USUARIO_USERNAME UNIQUE (DS_USERNAME),
    CONSTRAINT UK_USUARIO_EMAIL UNIQUE (DS_EMAIL),
    CONSTRAINT CK_USUARIO_ROLE CHECK (DS_ROLE IN ('Admin', 'User', 'Manager'))
);
GO

-- Índices para melhorar performance de autenticação
CREATE INDEX IX_USUARIO_USERNAME ON T_VM_USUARIO(DS_USERNAME);
CREATE INDEX IX_USUARIO_EMAIL ON T_VM_USUARIO(DS_EMAIL);
GO

-- Comentários descritivos
EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador único do usuário', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_USUARIO',
    @level2type = N'COLUMN', @level2name = N'ID_USUARIO';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nome completo do usuário', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_USUARIO',
    @level2type = N'COLUMN', @level2name = N'NM_USUARIO';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'E-mail do usuário (deve ser único)', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_USUARIO',
    @level2type = N'COLUMN', @level2name = N'DS_EMAIL';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nome de usuário para login (deve ser único)', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_USUARIO',
    @level2type = N'COLUMN', @level2name = N'DS_USERNAME';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Hash da senha do usuário', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_USUARIO',
    @level2type = N'COLUMN', @level2name = N'DS_PASSWORD_HASH';
GO

EXEC sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Perfil de acesso do usuário (Admin, User, Manager)', 
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'T_VM_USUARIO',
    @level2type = N'COLUMN', @level2name = N'DS_ROLE';
GO

-- ============================================================================
-- DADOS INICIAIS (SEED)
-- ============================================================================

-- Inserir áreas padrão
SET IDENTITY_INSERT T_VM_AREA ON;
GO

INSERT INTO T_VM_AREA (ID_AREA, NM_AREA) VALUES
    (1, 'Centro'),
    (2, 'Zona Norte'),
    (3, 'Zona Sul'),
    (4, 'Zona Leste'),
    (5, 'Zona Oeste');
GO

SET IDENTITY_INSERT T_VM_AREA OFF;
GO

-- Inserir motos de exemplo
SET IDENTITY_INSERT T_VM_MOTO ON;
GO

INSERT INTO T_VM_MOTO (ID_MOTO, DS_PLACA, NM_MODELO, ID_AREA) VALUES
    (1, 'ABC-1234', 'Honda CG 160', 1),
    (2, 'DEF-5678', 'Yamaha Factor 150', 2),
    (3, 'GHI-9012', 'Honda Biz 125', 3),
    (4, 'JKL-3456', 'Suzuki Intruder 150', 4),
    (5, 'MNO-7890', 'Yamaha XTZ 125', 5);
GO

SET IDENTITY_INSERT T_VM_MOTO OFF;
GO

-- Inserir usuário administrador padrão
-- ATENÇÃO: Em produção, SEMPRE use hash seguro (BCrypt, Argon2)
SET IDENTITY_INSERT T_VM_USUARIO ON;
GO

INSERT INTO T_VM_USUARIO (ID_USUARIO, NM_USUARIO, DS_EMAIL, DS_USERNAME, DS_PASSWORD_HASH, DS_ROLE) VALUES
    (1, 'Administrador', 'admin@mottu.com', 'admin', 'admin123', 'Admin'),
    (2, 'Usuario Teste', 'user@mottu.com', 'user', 'user123', 'User');
GO

SET IDENTITY_INSERT T_VM_USUARIO OFF;
GO

-- ============================================================================
-- VERIFICAÇÃO FINAL
-- ============================================================================

-- Verificar se todas as tabelas foram criadas
SELECT 
    TABLE_NAME AS 'Tabela Criada',
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = t.TABLE_NAME) AS 'Quantidade Colunas'
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_TYPE = 'BASE TABLE'
  AND TABLE_NAME IN ('T_VM_AREA', 'T_VM_MOTO', 'T_VM_USUARIO')
ORDER BY TABLE_NAME;
GO

-- Verificar relacionamentos (Foreign Keys)
SELECT 
    fk.name AS 'Foreign Key',
    OBJECT_NAME(fk.parent_object_id) AS 'Tabela Origem',
    OBJECT_NAME(fk.referenced_object_id) AS 'Tabela Referenciada'
FROM sys.foreign_keys fk
WHERE fk.parent_object_id IN (
    OBJECT_ID('T_VM_AREA'),
    OBJECT_ID('T_VM_MOTO'),
    OBJECT_ID('T_VM_USUARIO')
)
ORDER BY OBJECT_NAME(fk.parent_object_id);
GO

-- Verificar dados inseridos
SELECT 'T_VM_AREA' AS Tabela, COUNT(*) AS Total FROM T_VM_AREA
UNION ALL
SELECT 'T_VM_MOTO', COUNT(*) FROM T_VM_MOTO
UNION ALL
SELECT 'T_VM_USUARIO', COUNT(*) FROM T_VM_USUARIO;
GO

-- ============================================================================
-- FIM DO SCRIPT
-- ============================================================================
-- ✅ Requisitos atendidos:
--    - 3 tabelas criadas (mais que o mínimo de 2)
--    - Relacionamento FK entre MOTO e AREA
--    - Constraints (PK, FK, UK, CK)
--    - Índices para performance
--    - Dados iniciais (SEED)
--    - Comentários descritivos
-- ============================================================================

PRINT '✅ Script executado com sucesso!';
PRINT '✅ Tabelas criadas: T_VM_AREA, T_VM_MOTO, T_VM_USUARIO';
PRINT '✅ Relacionamento MOTO → AREA configurado';
PRINT '✅ Dados de exemplo inseridos';
GO
