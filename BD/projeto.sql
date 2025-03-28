create database projeto;
use projeto;

create table docentes(docente_id int auto_increment primary key,
 nome varchar(70),
 area varchar(30),
 contato varchar(15)
 );
 
 create table coordenadores(coordenador_id int auto_increment primary key,
 nome varchar(70),
 contato varchar(15)
 );
 
 create table turmas(turma_id int auto_increment primary key,
  nome varchar(70),
 curso varchar(30),
 periodo varchar(15),
 coordenador_id_fk int,
 foreign key (coordenador_id_fk) references coordenadores(coordenador_id)
 );
 
 create table horarios_docentes(hora_doc_id int auto_increment primary key,
 docente_id_fk int,
 turma_id_fk int,
 dia_semana varchar(15),
 hora_inicio time,
 hora_fim time,
 foreign key (docente_id_fk) references docentes(docente_id),
 foreign key ( turma_id_fk) references turmas( turma_id)
 );
 
 