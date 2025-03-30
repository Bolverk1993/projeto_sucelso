create database projeto1;
use projeto1;

-- Tabela para gerenciamento contatos dos professores e coordenadores
create table contatos(contato_id int auto_increment primary key,
nome varchar(70) not null,
telefone varchar(15) not null,
celular varchar(15),
email varchar(255) not null
);
 
 -- Tabela para gerenciamento dos coordenadores
 create table coordenadores(coordenador_id int auto_increment primary key,
 contato_id_fk int,
 codigo int,
 foreign key (contato_id_fk) references contatos(contato_id)
 );
 
-- Tabela para gerenciamento dos docentes
create table docentes(docente_id int auto_increment primary key,
 area varchar(30),
 contato_id_fk int,
 foreign key (contato_id_fk) references contatos(contato_id)
 );

 -- Tabela para gerenciamento das turmas
 create table turmas(turma_id int auto_increment primary key,
  nome varchar(70),
 curso varchar(30),
 periodo varchar(15)
 );
 
 -- Tabela para gerenciamento horarios de aula 
 create table horarios_docentes(hora_doc_id int auto_increment primary key,
 docente_id_fk int,
 turma_id_fk int,
 dia_semana enum ('Domingo','Segunda', 'Terça', 'Quarta', 'Quinta', 'Sexta', 'Sábado') not null,
 hora_inicio time,
 hora_fim time,
 foreign key (docente_id_fk) references docentes(docente_id),
 foreign key ( turma_id_fk) references turmas( turma_id)
 );
 
-- Tabela para gerenciamento de login e senha com nível de acesso
create table usuarios (usuarios_id int auto_increment primary key,
usuario varchar(50) unique not null,
senha varchar(255) not null,
nivel_acesso enum ('coordenador','professor') not null,
docente_id_fk int,
coordenador_id_fk int,
foreign key (docente_id_fk) references docentes(docente_id),
foreign key (coordenador_id_fk) references coordenadores(coordenador_id)
);
 
 
 
 -- INSERÇOES
 
 
 
 
 -- inserir contato
insert into contatos (nome, telefone, celular, email)
values ('Maria Clara', '(71) 3333-4444', '(71) 98888-7777', 'maria.clara@senai.com'),
('Álvaro', '(71) 5555-4444', '(71) 96969-7777', 'alvarinhoo@senai.com');
 
 -- inserir coordenador
insert into coordenadores (contato_id_fk, codigo)
values (1, 91118);

-- inserir docente
insert into docentes (area, contato_id_fk)
values ('português', 2);

-- inserir turma
insert into turmas (nome, curso, periodo)
values ('turma b', 'ensino fundamental', 'tarde');

-- inserir horário
insert into horarios_docentes (docente_id_fk, turma_id_fk, dia_semana, hora_inicio, hora_fim)
values (1, 1, 'terça', '13:00:00', '14:50:00');

-- inserir usuário
insert into usuarios (usuario, senha, nivel_acesso, docente_id_fk, coordenador_id_fk)
values ('coord.maria', sha2('senha456', 256), 'coordenador', null, 1),
('prof.alvaro', sha2('senha852', 256), 'professor', 1, null);




-- ATUALIZAÇÃO DE REGISTROS




-- atualizar contato
update contatos 
set telefone = '(69) 5555-6666', email = 'maria.nova@FIEB.com'
where contato_id = 1;

-- atualizar docente
update docentes
set area = 'literatura'
where docente_id = 1;

-- atualizar horário
update horarios_docentes
set hora_inicio = '13:30:00', hora_fim = '15:30:00'
where hora_doc_id = 1;

-- atualizar usuário
update usuarios
set senha = sha2('novaSenha789', 256)
where usuarios_id = 2;



-- APAGANDO



-- remover horário
delete from horarios_docentes
where hora_doc_id = 1;


-- remover  COODENADOR E CONTATO RESPECTIVO
-- 1. Primeiro obtenha o coordenador_id:
set @coordenador_id := (select coordenador_id from coordenadores where contato_id_fk = 3);
-- 2. Execute em uma transação:
start transaction;
    delete from usuarios where coordenador_id_fk = @coordenador_id;
    delete from coordenadores where contato_id_fk = 3;
    delete from contatos where contato_id = 3;
commit;


-- remover  DOCENTE E CONTATO RESPECTIVO
-- 1. Encontre o docente_id associado ao contato
SET @docente_id := (SELECT docente_id FROM docentes WHERE contato_id_fk = 2);
-- 2. Inicie a transação
start transaction;
-- 3. Remova todos os horários do docente (se existirem)
DELETE FROM horarios_docentes WHERE docente_id_fk = @docente_id;
-- 4. Remova o usuário associado (se existir)
DELETE FROM usuarios WHERE docente_id_fk = @docente_id;
-- 5. Remova o docente
DELETE FROM docentes WHERE contato_id_fk = 2;
-- 6. Finalmente remova o contato
DELETE FROM contatos WHERE contato_id = 2;
-- 7. Confirme a transação
commit;




 -- CONSULTAS
 
 
 -- horários de um dia
select * from horarios_docentes
where dia_semana = 'terça';

-- horários da semana
select * from horarios_docentes
where dia_semana in ('segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado')
order by field(dia_semana, 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'), hora_inicio;

-- todas as turmas
select * from turmas
order by nome;

-- turmas por curso
select * from turmas
where curso = 'ensino fundamental';

-- turmas por período
select * from turmas
where periodo = 'tarde';

-- docente com filtro de dia
select h.*, t.nome as turma_nome 
from horarios_docentes h
join turmas t on h.turma_id_fk = t.turma_id
where h.docente_id_fk = 2 and h.dia_semana = 'terça'
order by h.hora_inicio;

-- turma com filtro de semana
select h.*, d.area as disciplina, c.nome as professor
from horarios_docentes h
join docentes d on h.docente_id_fk = d.docente_id
join contatos c on d.contato_id_fk = c.contato_id
where h.turma_id_fk = 2 and h.dia_semana in ('segunda', 'terça', 'quarta')
order by field(h.dia_semana, 'segunda', 'terça', 'quarta'), h.hora_inicio;

-- horário diário
select h.dia_semana, h.hora_inicio, h.hora_fim, d.area as disciplina, c.nome as professor
from horarios_docentes h
join docentes d on h.docente_id_fk = d.docente_id
join contatos c on d.contato_id_fk = c.contato_id
where h.turma_id_fk = 2 and h.dia_semana = 'sexta'
order by h.hora_inicio;

-- grade semanal
select h.dia_semana, h.hora_inicio, h.hora_fim, d.area as disciplina, c.nome as professor
from horarios_docentes h
join docentes d on h.docente_id_fk = d.docente_id
join contatos c on d.contato_id_fk = c.contato_id
where h.turma_id_fk = 2
order by field(h.dia_semana, 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'), h.hora_inicio;

-- Relatório mensal para um docente específico
SELECT 
    CONCAT('Semana ', 
           WEEK(h.dia_semana, 1) - WEEK(DATE_FORMAT(CURRENT_DATE(), '%Y-%m-01'), 1) + 1) AS semana_mes,
    h.dia_semana,
    h.hora_inicio,
    h.hora_fim,
    t.nome AS turma,
    t.curso,
    COUNT(*) OVER (PARTITION BY h.dia_semana) AS total_aulas_dia
FROM 
    horarios_docentes h
JOIN 
    turmas t ON h.turma_id_fk = t.turma_id
WHERE 
    h.docente_id_fk = 2
ORDER BY 
    semana_mes,
    FIELD(h.dia_semana, 'segunda', 'terça', 'quarta', 'quinta', 'sexta', 'sábado'),
    h.hora_inicio;


-- RELATORIOS

-- docentes e horários
select c.nome, d.area, h.dia_semana, h.hora_inicio, h.hora_fim, t.nome as turma
from docentes d
join contatos c on d.contato_id_fk = c.contato_id
left join horarios_docentes h on d.docente_id = h.docente_id_fk
left join turmas t on h.turma_id_fk = t.turma_id
order by c.nome, h.dia_semana, h.hora_inicio;

-- turmas e professores
select t.nome as turma, t.curso, t.periodo, 
       group_concat(distinct c.nome separator ', ') as professores
from turmas t
join horarios_docentes h on t.turma_id = h.turma_id_fk
join docentes d on h.docente_id_fk = d.docente_id
join contatos c on d.contato_id_fk = c.contato_id
group by t.turma_id;


 