USE Sinergias_db
GO

CREATE TABLE cierreforward (
    ano INT NOT NULL,
    periodo INT NOT NULL,
    id INT NOT NULL,
    valor NUMERIC(18,2) NOT NULL,
    observaciones VARCHAR(200) NOT NULL,
    fecha DATETIME NOT NULL,
    usuario VARCHAR(50),
    FOREIGN KEY (id) REFERENCES forward(id),
    FOREIGN KEY (usuario) REFERENCES usuarios(nick)
)

ALTER TABLE creditoforward
ADD seqid INT DEFAULT NULL