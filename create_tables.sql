
drop table if exists READER_BOOK;
drop table if exists BOOK_EXAMPLE;   
drop table if exists BOOK_AUTHOR;
drop table if exists D_BOOK; 
drop table if exists D_READER;
drop table if exists D_AUTHOR;
drop table if exists D_STYLE;



/*==============================================================*/
/* Table: D_AUTHOR                                              */
/*==============================================================*/
create table D_AUTHOR
(
ID_AUTHOR int not null default 0,
NAME_AUTHOR varchar(250) not null,
DESCRIPTION varchar(4000),
primary key (ID_AUTHOR)
);

/*==============================================================*/
/* Table: D_READER                                               */
/*==============================================================*/
create table D_READER
(
ID_READER int not null default 0,
CODE_READER varchar(210) not null,
NAME_READER varchar(250) not null,
DESCRIPTION varchar(4000),
primary key (ID_READER)
);


/*==============================================================*/
/* Table: D_STYLE                                              */
/*==============================================================*/
create table D_STYLE
(
ID_STYLE int not null default 0,
NAME_STYLE varchar(250) not null,
DESCRIPTION varchar(4000),
primary key (ID_STYLE)
);


/*==============================================================*/
/* Table: D_BOOK                                                */
/*==============================================================*/
create table D_BOOK
(
ID_BOOK int not null,
ID_STYLE int not null,
NAME_BOOK varchar(250) not null,
DESCRIPTION varchar(4000),
PAGE_NUM int,
BOOK_YEAR varchar(4),
primary key (ID_BOOK),
constraint FK_D_BOOK__D_STYLE 
foreign key (ID_STYLE)
references D_STYLE(ID_STYLE) 
on delete restrict on update restrict
);


/*==============================================================*/
/* Table: BOOK_AUTHOR                                                   */
/*==============================================================*/
create table BOOK_AUTHOR
(
ID_AUTHOR int not null,
ID_BOOK int not null,
POS_AUTHOR int,
primary key (ID_AUTHOR, ID_BOOK),
constraint FK_BOOK_AUTHOR__D_AUTHOR
foreign key (ID_AUTHOR)
references D_AUTHOR(ID_AUTHOR) 
on delete restrict on update restrict,
constraint FK_BOOK_AUTHOR__D_BOOK 
foreign key (ID_BOOK)
references D_BOOK(ID_BOOK) 
on delete restrict on update restrict

);



/*==============================================================*/
/* Table: BOOK_EXAMPLE                                                   */
/*==============================================================*/
create table BOOK_EXAMPLE
(
ID_BOOK_EXAMPLE int not null,
ID_BOOK int not null,
CODE_BOOK varchar(10) not null unique,
DESCRIPTION varchar(4000),
IS_READABLE int not null,
primary key (ID_BOOK_EXAMPLE),
constraint FK_BOOK_EXAMPLE__D_BOOK 
foreign key (ID_BOOK) 
references D_BOOK(ID_BOOK) 
on delete restrict on update restrict
);



/*==============================================================*/
/* Table: READER_BOOK                                                   */
/*==============================================================*/
create table READER_BOOK
(
ID_READER_BOOK int not null,
ID_BOOK_EXAMPLE int not null,
ID_READER int not null,
DATE_START datetime,
TERM int,
DATE_END_PL datetime,
DATE_END_AC datetime,
primary key (ID_READER_BOOK),
constraint FK_READER_BOOK__BOOK_EXAMPLE
foreign key (ID_BOOK_EXAMPLE)
references BOOK_EXAMPLE(ID_BOOK_EXAMPLE)
on delete restrict on update restrict,

constraint FK_READER_BOOK__D_READER
foreign key (ID_READER) 
references D_READER(ID_READER) 
on delete restrict on update restrict
);




/*==============================================================*/
/* Indexes                                                      */
/*==============================================================*/
create index IDX_CODE_READER_ on D_READER (CODE_READER);

