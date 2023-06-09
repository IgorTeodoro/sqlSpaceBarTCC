CREATE DATABASE SpaceBar
GO

Use SpaceBar
GO

create table tipo_usuario
(
	cod_tipo int primary key identity,
	descricao varchar(30),
);
GO
create table tblUsuario
(
    cod_usuario int primary key identity,
    cod_tipo int,
    nome_usuario varchar(30),
    login_usuario varchar(20),
    senha_usuario varchar(100),
    email_usuario varchar(30),
    pais_usuario varchar(30),
    cel_usuario varchar(13),
    icon_usuario varbinary(max),
    imgfundo_usuario varbinary (max),
    data_criacao date not null,
    bio_usuario varchar(150),
	/*verificado*/
	status_verificado varchar(20) default 'nenhum' not null,
	mensagem_verificado varchar(300),
	profissao varchar(20),
	img_comprovante varbinary (max),
	foreign key (cod_tipo) references tipo_usuario,
	check ([status_verificado]='nenhum' OR [status_verificado]='aceito' OR [status_verificado]='pendente' OR [status_verificado]='negado')
);

Select * from tblUsuario

Delete from tblUsuario

GO
create table tblPost
(
	cod_post int primary key identity,
	cod_usuario int,
	titulo_post varchar(300) not null,
	texto_post varchar(100),
	img_post VARBINARY(max),
	data_post datetime not null,
	verificado bit default 0 not null,
	foreign key (cod_usuario) references tblUsuario,
);
GO
create table tblComentarios
(
	cod_comentario int identity,
	cod_post int,
	cod_usuario int,
	conteudo_comentario varchar(200) not null,
	data_comentario datetime not null,
	primary key (cod_comentario),
	foreign key (cod_post) references tblPost,
	foreign key (cod_usuario) references tblUsuario
);
GO
create table tblSeguidores
(
	id_usuario_seguidor int not null,
	id_usuario_alvo int not null,
	foreign key (id_usuario_seguidor) references tblUsuario,
	foreign key (id_usuario_alvo) references tblUsuario
);
GO
SET IDENTITY_INSERT tipo_usuario ON;

insert into tipo_usuario(cod_tipo,descricao) values(1, 'Usuario comum')
insert into tipo_usuario(cod_tipo,descricao) values(2, 'Criador de conteúdo')
insert into tipo_usuario(cod_tipo,descricao) values(3, 'Verificado')
insert into tipo_usuario(cod_tipo,descricao) values(4, 'Verificado/criador de conteúdo')
insert into tipo_usuario(cod_tipo,descricao) values(5, 'ADM')

create table tblPostagemCurtidas
(
    tblPostagemCurtidas_cod_usuario int,

    tblPostagemCurtidas_cod_post int,
    foreign key (tblPostagemCurtidas_cod_usuario) references tblUsuario,
    foreign key (tblPostagemCurtidas_cod_post) references tblPost,
    data_curtida date default GETDATE()
);
GO
-- pega todos os cod_post em ordem crescente
CREATE PROCEDURE GetCodPostagensCrescente
AS
begin
    SELECT cod_post FROM tblPost ORDER BY cod_post ASC
end
GO

-- pega todo o conteÃºdo de um post junto com as informaÃ§Ãµes de quem o criou
CREATE PROCEDURE GetPostAndAuthor
AS
begin
    SELECT * from tblPost INNER JOIN tblUsuario tU on tU.cod_usuario = tblPost.cod_usuario
end
GO
-- obtem a quantidade de posts que tem no banco de dados inteiro
CREATE PROCEDURE GetPostsQuantity
AS
begin
    SELECT COUNT(cod_post) FROM tblPost
end
GO
-- obtem todos os dados de todos os posts
CREATE PROCEDURE GetPost
AS
begin
    SELECT * FROM tblPost
end
GO

-- verificar se um post especifico Ã© verificado (true ou false)
CREATE PROCEDURE GetPostVerified
    @cod_post int
AS
begin
    SELECT verificado FROM tblPost WHERE cod_post = @cod_post
end
GO
CREATE PROCEDURE GetPostQuantityLikes
    @postID int
AS
begin
    SELECT COUNT(tblPostagemCurtidas_cod_usuario) FROM tblPostagemCurtidas WHERE tblPostagemCurtidas_cod_post = @postID
end
GO
CREATE PROCEDURE GetPostById
    @postId int
AS
    BEGIN
        SELECT * FROM tblPost WHERE cod_post = @postId
    END
GO
CREATE PROCEDURE GetPostAndAuthorById
    @postId int
AS
    BEGIN
        SELECT * FROM tblPost INNER JOIN tblUsuario tU on tU.cod_usuario = tblPost.cod_usuario WHERE tblPost.cod_post = @postId
    end
GO
CREATE PROCEDURE CheckUserHasLiked
    @postId int,
    @userId int
AS
begin
    SELECT COUNT(*) FROM tblPostagemCurtidas WHERE tblPostagemCurtidas_cod_post = @postId AND tblPostagemCurtidas_cod_usuario = @userId
end
GO
CREATE PROCEDURE GetAuthorPost
    @postId int
AS
begin
    -- select the cod_usuario from tblUsuario where the cod_usuario equals to the creator of an specific post --
    SELECT cod_usuario FROM tblPost WHERE cod_post = @postId
end
GO
CREATE PROCEDURE DeleteLike
    @postId int,
    @userId int
AS
begin
    DELETE FROM tblPostagemCurtidas WHERE tblPostagemCurtidas_cod_post = @postId AND tblPostagemCurtidas_cod_usuario = @userId
end
GO
CREATE PROCEDURE AddLike
    @postId int,
    @userId int
AS
begin
    INSERT INTO tblPostagemCurtidas (tblPostagemCurtidas_cod_post, tblPostagemCurtidas_cod_usuario, data_curtida) VALUES (@postId, @userId, GETDATE())
end
GO
CREATE PROCEDURE GetAllInfoAndPostsByAuthor
    @postAuthorID int
AS
begin
    SELECT * FROM tblPost INNER JOIN tblUsuario tU ON tU.cod_usuario = tblPost.cod_usuario WHERE tblPost.[cod_usuario] = @postAuthorID
end
GO
CREATE PROCEDURE GetuserInformation
    @userId int
AS
begin
    SELECT * FROM tblUsuario WHERE cod_usuario = @userId
end
GO
CREATE PROCEDURE GetQuantityFollowing
    @userId int
AS
begin
    SELECT COUNT(*) AS FollowingCount FROM tblSeguidores WHERE id_usuario_seguidor = @userId
end
GO
CREATE PROCEDURE GetQuantityFollowers
    @userId int
AS
begin
    SELECT COUNT(*) AS FollowersCount FROM tblSeguidores WHERE id_usuario_alvo = @userId
end
GO
CREATE PROCEDURE FollowUser
    @usuario_seguidor int,
    @usuario_alvo int
AS
begin
    INSERT INTO tblSeguidores (id_usuario_seguidor,id_usuario_alvo) VALUES (@usuario_seguidor, @usuario_alvo)
end
GO

-- verifica se o seguidor_alvo ja está sendo seguindo pelo usuário logado
CREATE PROCEDURE VerifyIfUserIsAlreadyBeingFollowed
    @usuario_seguidor int,
    @usuario_alvo int
AS
begin
    -- verifica se o usuario seguidor (logado) segue o usuario alvo (perfil desejado) --
    SELECT COUNT(id_usuario_seguidor) FROM tblSeguidores WHERE id_usuario_alvo = @usuario_alvo AND id_usuario_seguidor = @usuario_seguidor
end
GO
CREATE PROCEDURE UnfollowUser
    @usuario_seguidor int,
    @usuario_alvo int
AS
begin
    DELETE FROM tblSeguidores WHERE id_usuario_seguidor = @usuario_seguidor AND id_usuario_alvo = @usuario_alvo
end
GO
--procedure inscrever--
Create Procedure SelectVerificarLoginEmail
    @login varchar(20),
    @email varchar(30)
as
begin
	select login_usuario, email_usuario
	from tblUsuario
	WHERE login_usuario = @login OR email_usuario = @email
end
GO
Create Procedure InsertInscrever
@tipo_usu int,
@nome varchar (30),
@login varchar(20),
@email varchar(30),
@cel varchar (13),
@pais varchar(30),
@senha varchar (100),
@data date
as
begin
	insert into tblUsuario(cod_tipo,nome_usuario,login_usuario,email_usuario,cel_usuario,pais_usuario,senha_usuario,data_criacao) values (@tipo_usu,@nome, @login, @email, @cel, @pais, @senha, @data);
end
GO
/*Create procedure SelectCodTipo */
Create procedure SelectCodTipo
@codUsuarioConectado int
as
begin
	select cod_tipo
	from tblUsuario
	WHERE cod_usuario = @codUsuarioConectado
end
GO
--  procedure login--
create procedure spacelogin
	@loguser varchar(20)
As
Begin
	Select * from tblUsuario where login_usuario = @loguser
END
GO
CREATE PROCEDURE LoginUsuario
    @email_usuario varchar(30)
AS
    BEGIN
       SELECT * FROM tblUsuario WHERE email_usuario = @email_usuario
    END
GO
-- irá contar quantas vezes determinada postagem aparece na tabela de relações
CREATE PROCEDURE GetCommentsQuantity
    @PostId  int
AS
    BEGIN
        SELECT COUNT(*) AS quantidade_comentarios FROM tblComentarios WHERE cod_post = @PostId
    end
GO
-- irá inserir um comentario na tabela de comentarios
CREATE PROCEDURE InsertComment
    @cod_post int,
    @cod_usuario int,
    @comentario varchar(200)
AS
    BEGIN
        INSERT INTO tblComentarios (cod_post, cod_usuario, conteudo_comentario) VALUES (@cod_post, @cod_usuario, @comentario)
    end
GO
CREATE PROCEDURE InsertPost
    @titulo VARCHAR(300),
    @texto VARCHAR(100)=null ,
    @data DATETIME,
    @imagem NVARCHAR(MAX)=null,
    @id INT
AS
BEGIN
    INSERT INTO tblPost (titulo_post, texto_post, data_post, img_post, cod_usuario)
     VALUES (@titulo, @texto, @data, CONVERT(VARBINARY(MAX), @imagem), @id)
END
GO
CREATE PROCEDURE GetComments
    @PostId  int
AS
    BEGIN
        SELECT * FROM tblComentarios WHERE cod_post = @PostId
    end
GO
CREATE PROCEDURE Comentar
    @cod_post int,
    @cod_usuario int,
    @comentario varchar(200)
AS
    BEGIN
        INSERT INTO tblComentarios (cod_post, cod_usuario, conteudo_comentario,  data_comentario) VALUES (@cod_post, @cod_usuario, @comentario, GETDATE())
    end
GO
-- conta a quantidade de postagens criadas no ultimo dia --
CREATE PROCEDURE CountCreatedPosts
AS
    BEGIN
        SELECT COUNT(*) AS quantidade_postagens FROM tblPost WHERE data_post > DATEADD(HOUR, -24, GETDATE())
    end
GO
-- conta a quantidade de usuários registrados no ultimo dia --
CREATE PROCEDURE CountRegisteredUsers
AS
    BEGIN
        SELECT COUNT(*) AS quantidade_usuarios FROM tblUsuario WHERE data_criacao > DATEADD(HOUR, -24, GETDATE())
    end
GO

-- conta a quantidade de comentários criados no ultimo dia --
CREATE PROCEDURE CountCreatedComments
AS
    BEGIN
        SELECT COUNT(*) AS quantidade_comentarios FROM tblComentarios WHERE data_comentario > DATEADD(HOUR, -24, GETDATE())
    end
GO

-- conta a quantidade de curtidas criadas no geral no  ultimo dia --
CREATE PROCEDURE CountCreatedLikes
AS
    BEGIN
        SELECT COUNT(*) AS quantidade_curtidas FROM tblPostagemCurtidas WHERE data_curtida > DATEADD(HOUR, -24, GETDATE())
    end
GO

CREATE PROCEDURE SearchLogin
@login varchar(20)
AS
    BEGIN
        SELECT * FROM tblUsuario WHERE login_usuario LIKE '%'+@login+'%'
    end
GO

CREATE PROCEDURE SelectVerificadoPendentes
AS
    BEGIN
        SELECT * FROM tblUsuario WHERE status_verificado = 'pendente'
    end
GO

CREATE PROCEDURE GetPostsQntdByUser
@userId int
AS
    BEGIN
        SELECT COUNT(*) AS qntd_posts FROM tblPost WHERE cod_usuario = @userId
    end
GO

CREATE PROCEDURE InsertNegado
@codUsuario int,
@mensagem varchar(300)

AS
    BEGIN
        UPDATE tblUsuario SET status_verificado = 'negado', mensagem_verificado = @mensagem WHERE cod_usuario = @codUsuario
    end
GO
CREATE PROCEDURE InsertAceito
@codUsuario int,
@mensagem varchar(300)
AS
    BEGIN
        UPDATE tblUsuario SET status_verificado = 'aceito', mensagem_verificado = @mensagem WHERE cod_usuario = @codUsuario
    end
GO
CREATE PROCEDURE SelectVerificadoAceito
AS
    BEGIN
        SELECT count(cod_usuario) FROM tblUsuario WHERE status_verificado = 'aceito'
    end
GO
CREATE PROCEDURE SelectVerificadoNegado
AS
    BEGIN
        SELECT count(cod_usuario) FROM tblUsuario WHERE status_verificado = 'negado'
    end
GO
CREATE PROCEDURE SelectVerificadoPendente
AS
    BEGIN
        SELECT count(cod_usuario) FROM tblUsuario WHERE status_verificado = 'pendente'
    end
GO
CREATE PROCEDURE SelectAllVerificadoPendente
AS
    BEGIN
        SELECT * FROM tblUsuario WHERE status_verificado = 'pendente'
    end
GO
CREATE PROCEDURE ObterQuantidadeUsuariosPorHierarquia
AS
BEGIN
    SELECT
        COUNT(*) AS QuantidadeUsuarios,
        CASE cod_tipo
            WHEN 1 THEN 'Usuario comum'
            WHEN 2 THEN 'Criador de conteúdo'
            WHEN 3 THEN 'Verificado'
            WHEN 4 THEN 'Verificado/criador de conteúdo'
            WHEN 5 THEN 'ADM'
        END AS Hierarquia
    FROM
        tblUsuario
    GROUP BY
        cod_tipo;
END
GO
CREATE PROCEDURE ObterQuantidadeUsuariosCriadosPorData
AS
    BEGIN
        SELECT data_criacao, COUNT(*) AS QuantidadeUsuarios FROM tblUsuario GROUP BY data_criacao ORDER BY data_criacao ASC
    end
GO
CREATE PROCEDURE PesquisarUsuario
@login_usuario VARCHAR(50)
AS
BEGIN
    SELECT * FROM tblUsuario WHERE login_usuario LIKE '%' + @login_usuario + '%';
END
GO
CREATE PROCEDURE VerificarPostagem
@codPost int
AS
    BEGIN
        --porque a procedure abaixo está com problemas? --
        UPDATE tblPost SET verificado = 1 WHERE cod_post = @codPost;
    end
GO
CREATE PROCEDURE InvalidarPostagem
@codPost int
AS
    BEGIN
            UPDATE tblPost SET verificado = 0 WHERE cod_post = @codPost;
    END
GO
CREATE PROCEDURE AtualizarCelular
@cel varchar(13),
@codUsuarioConectado int
AS
    BEGIN
        Update tblUsuario set cel_usuario=@cel where cod_usuario = @codUsuarioConectado
    end
GO
CREATE PROCEDURE AtualizarEmail
@email varchar(50),
@codUsuarioConectado int
AS
    BEGIN
        Update tblUsuario set email_usuario=@email where cod_usuario = @codUsuarioConectado
    end
GO
CREATE PROCEDURE AtualizarNomeUsuario
@nomeUsuario varchar(20),
@codUsuarioConectado int
AS
    BEGIN
        Update tblUsuario set nome_usuario=@nomeUsuario where cod_usuario = @codUsuarioConectado
    end
GO
CREATE PROCEDURE AtualizarSenha
@novaSenha varchar(100),
@codUsuarioConectado int
AS
    BEGIN
        Update tblUsuario set senha_usuario=@novaSenha where cod_usuario = @codUsuarioConectado
    end
GO
CREATE PROCEDURE AtualizarPais
@pais varchar(30),
@codUsuarioConectado int
AS
    BEGIN
        Update tblUsuario set pais_usuario=@pais where cod_usuario = @codUsuarioConectado
    end
GO
CREATE PROCEDURE SelecionarSelos
@codUsuarioConectado int
AS
    BEGIN
        SELECT cod_tipo from tblUsuario where cod_usuario = @codUsuarioConectado
    end
GO
CREATE PROCEDURE InserirImagemFundo
@imgFundo varbinary(max),
@codUsuarioConectado int
AS
BEGIN
    UPDATE tblUsuario SET imgfundo_usuario = @imgfundo WHERE cod_usuario = @codUsuarioConectado
end
GO
CREATE PROCEDURE InserirImagemPerfil
@icon varbinary(max),
@codUsuarioConectado int
AS
    BEGIN
        UPDATE tblUsuario SET icon_usuario = @icon WHERE cod_usuario = @codUsuarioConectado
    end
GO
CREATE PROCEDURE AtualizarNome
@codUsuarioConectado int,
@nome varchar(30)
AS
    BEGIN
        Update tblUsuario set nome_usuario=@nome where cod_usuario = @codUsuarioConectado
    end
GO
CREATE PROCEDURE AtualizarBioUsuario
@bio varchar(150),
@codUsuarioConectado int
AS
    BEGIN
        Update tblUsuario set bio_usuario=@bio where cod_usuario = @codUsuarioConectado
    end
GO