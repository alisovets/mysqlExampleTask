/* 1. Select the day of the week of your birthday. */
select '1970-07-19' as date, DAYNAME('1970-07-19') as week_day;


/* 2. Determine the number of books each style and the total number of books.*/
select NAME_STYLE, count(ID_BOOK) from D_STYLE S, D_BOOK B where B.ID_STYLE = S.ID_STYLE  group by NAME_STYLE, S.ID_STYLE;

select NAME_STYLE, count(ID_BOOK) 
from 
D_STYLE S
left join 
D_BOOK B 
on B.ID_STYLE = S.ID_STYLE  
group by NAME_STYLE, S.ID_STYLE
union
select 'all', count(ID_BOOK) from D_BOOK B;


/* 3. Determine the number of copies of books each style and the total number of the books. */
select S.NAME_STYLE, count(E.ID_BOOK) 
from 
D_STYLE S
left join 
D_BOOK B 
on B.ID_STYLE = S.ID_STYLE
left join
BOOK_EXAMPLE E
on B.ID_BOOK = E.ID_BOOK
group by  S.NAME_STYLE, S.ID_STYLE; 


/* 4. Select books that are written by Rimbaud and Buch. */
select distinct B.ID_BOOK, B.NAME_BOOK
from D_BOOK B, D_AUTHOR A, BOOK_AUTHOR R
where (A.NAME_AUTHOR like 'Buch %' or A.NAME_AUTHOR like 'Rimbaud %') and (R.ID_AUTHOR = A.ID_AUTHOR and B.ID_BOOK = R.ID_BOOK);


/* 5. Select books that are written by both of Rimbaud and Buch in collaboration (without other co-authors).*/
select BB.ID_BOOK, BB.NAME_BOOK
from (
    select B.ID_BOOK, B.NAME_BOOK
    from D_BOOK B, D_AUTHOR A, BOOK_AUTHOR R
    where (A.NAME_AUTHOR like 'Buch %' or A.NAME_AUTHOR like 'Rimbaud %') and R.ID_AUTHOR = A.ID_AUTHOR and B.ID_BOOK = R.ID_BOOK
    group by B.NAME_BOOK, B.ID_BOOK
    having count(A.NAME_AUTHOR)=2
) BB, BOOK_AUTHOR BA
where BB.ID_BOOK = BA.ID_BOOK
group by BB.ID_BOOK, BB.NAME_BOOK
having count(BA.ID_BOOK) = 2;


/* 6. Select the names of the most active readers. */
select NAME_READER, count(ID_READER_BOOK) as C
from D_READER R, READER_BOOK B
where B.ID_READER = R.ID_READER
group by NAME_READER
order by C desc limit 5;


/* 7. Determine readers never read books style "pink snot".*/
select ID_READER, NAME_READER from D_READER
where ID_READER not in(
  select R.ID_READER
  from D_READER R, READER_BOOK RB, BOOK_EXAMPLE BE, D_BOOK B, D_STYLE S
  where
    RB.ID_READER = R.ID_READER and RB.ID_BOOK_EXAMPLE = BE.ID_BOOK_EXAMPLE
    and BE.ID_BOOK = B.ID_BOOK and B.ID_STYLE = S.ID_STYLE
    and S.NAME_STYLE = 'Pink snot'
 );


/* 8. Determine of authors who write books in only one style. */
select ID_AUTHOR, NAME_AUTHOR
from(
    select distinct A.ID_AUTHOR, A.NAME_AUTHOR, S.ID_STYLE
    from D_AUTHOR A, BOOK_AUTHOR BA, D_BOOK B, D_STYLE S
    where A.ID_AUTHOR = BA.ID_AUTHOR and BA.ID_BOOK = B.ID_BOOK and B.ID_STYLE = S.ID_STYLE
) A
group by ID_AUTHOR
having count(ID_STYLE) = 1;
;

/* 9. Determine of authors which not less than 2 different styles writing book. */
select ID_AUTHOR, NAME_AUTHOR, count(ID_STYLE)
from(
    select distinct A.ID_AUTHOR, A.NAME_AUTHOR, S.ID_STYLE
    from D_AUTHOR A, BOOK_AUTHOR BA, D_BOOK B, D_STYLE S
    where A.ID_AUTHOR = BA.ID_AUTHOR and BA.ID_BOOK = B.ID_BOOK and B.ID_STYLE = S.ID_STYLE
) A
group by ID_AUTHOR
having count(ID_STYLE) >= 2;
;

/* 10. Determine the top 10 books.*/
select B.ID_BOOK, B.NAME_BOOK, count(R.ID_READER_BOOK) as C
from D_BOOK B, BOOK_EXAMPLE E, READER_BOOK R
where B.ID_BOOK = E.ID_BOOK and R.ID_BOOK_EXAMPLE = E.ID_BOOK_EXAMPLE
group by B.ID_BOOK, B.NAME_BOOK
order by  C desc limit 10;

/* 11. Determine the most popular book styles.*/
select S.NAME_STYLE, count(R.ID_READER_BOOK) as C
from D_BOOK B, BOOK_EXAMPLE E, READER_BOOK R, D_STYLE S
where B.ID_BOOK = E.ID_BOOK and R.ID_BOOK_EXAMPLE = E.ID_BOOK_EXAMPLE AND S.ID_STYLE = B.ID_STYLE
group by S.ID_STYLE, S.NAME_STYLE
order by  C desc;

/* 12. Determine the most popular writers. */
select A.NAME_AUTHOR, count(R.ID_READER_BOOK) as C
from D_BOOK B, BOOK_EXAMPLE E, READER_BOOK R, D_AUTHOR A, BOOK_AUTHOR BA
where B.ID_BOOK = E.ID_BOOK and R.ID_BOOK_EXAMPLE = E.ID_BOOK_EXAMPLE and B.ID_BOOK = BA.ID_BOOK  and A.ID_AUTHOR = BA.ID_AUTHOR
group by A.ID_AUTHOR, A.NAME_AUTHOR
order by  C desc;
;

/* 13. Determine the names and codes of readers who have at hand at least 3 books.*/
select R.CODE_READER, R.NAME_READER, count(B.ID_READER_BOOK) 'NUMBER OF BOOKS'
from  D_READER R, READER_BOOK B
where R.ID_READER = B.ID_READER and B.DATE_END_AC is null
group by R.ID_READER, R.CODE_READER, R.NAME_READER
having  count(B.ID_READER_BOOK) >= 3
;

/* 14. Determine names of readers which at least once detained the book more, than for 10 days. */
select distinct R.CODE_READER, R.NAME_READER
from  D_READER R, READER_BOOK B
where R.ID_READER = B.ID_READER and 
    ((B.DATE_END_AC is not  null and  datediff(B.DATE_END_AC, B.DATE_END_PL) > 10) or 
    (B.DATE_END_AC is null and datediff(now(), B.DATE_END_PL) > 10))
;

/* 15. Determine names of readers who read books of one style only. */
select ID_READER, NAME_READER, count(ID_STYLE)
from(
    select distinct R.ID_READER, R.NAME_READER, B.ID_STYLE
    from D_READER R, READER_BOOK RB, BOOK_EXAMPLE BE, D_BOOK B
    where RB.ID_READER = R.ID_READER and RB.ID_BOOK_EXAMPLE = BE.ID_BOOK_EXAMPLE
        and BE.ID_BOOK = B.ID_BOOK
) Z
group by ID_READER, NAME_READER
having count(ID_STYLE) = 1
;    

/* 16. Select names of readers who never read the same book.*/
select R.ID_READER, R.NAME_READER
from D_READER R
where R.ID_READER in (
    select RB.ID_READER
    from READER_BOOK RB, BOOK_EXAMPLE BE
    where R.ID_READER = RB.ID_READER and RB.ID_BOOK_EXAMPLE = BE.ID_BOOK_EXAMPLE 
    group by RB.ID_READER, BE.ID_BOOK
    having count(BE.ID_BOOK) > 1
);


/* 17. Determine the names of readers who take more than the average one. */
select R.ID_READER, R.NAME_READER, count(RB.ID_READER_BOOK) BOOK_COUNT
from D_READER R, READER_BOOK RB
where R.ID_READER = RB.ID_READER
group by R.ID_READER, R.NAME_READER
having 
    count(RB.ID_READER_BOOK) > 
    (select count(RB.ID_READER_BOOK) from READER_BOOK RB) / (select count(R.ID_READER) from D_READER R)
order by BOOK_COUNT desc, R.NAME_READER;



/* 18. Determine the author who wrote the maximum number of books. */
select A.ID_AUTHOR, A.NAME_AUTHOR, count(B.ID_BOOK) as COUNT_BOOK
from D_AUTHOR A, BOOK_AUTHOR B 
where A.ID_AUTHOR = B.ID_AUTHOR
group by A.ID_AUTHOR, A.NAME_AUTHOR
order by COUNT_BOOK desc
limit 0, 1
;

/* 19. Determine the number of books of each style for the author "King". */
select S.NAME_STYLE, count(B.ID_BOOK)
from D_STYLE S, D_BOOK B, D_AUTHOR A, BOOK_AUTHOR BA
where A.NAME_AUTHOR like 'King%'  and  BA.ID_AUTHOR = A.ID_AUTHOR and BA.ID_BOOK = B.ID_BOOK and B.ID_STYLE = S.ID_STYLE
group by NAME_STYLE , S.ID_STYLE;


/* 20. Determine names of months in which the maximum number of books is taken. */
select MONTHNAME(DATE_START) as month, count(ID_READER_BOOK) book_count
from READER_BOOK
group by month
order by book_count desc 
limit 0, 6
;

/* 21.Determine number of books that have good copies less than 50%. */
select D_BOOK.ID_BOOK, D_BOOK.NAME_BOOK 
from 
   (select BE.ID_BOOK, count(BE.ID_BOOK_EXAMPLE) as BAD_COUNT
    from BOOK_EXAMPLE BE 
    where BE.IS_READABLE = 0
    group by BE.ID_BOOK) B 
inner join
(select BE.ID_BOOK, count(BE.ID_BOOK_EXAMPLE) as GOOD_COUNT

    from BOOK_EXAMPLE BE 
    where BE.IS_READABLE = 1
    group by BE.ID_BOOK) G 
on B.ID_BOOK = G.ID_BOOK
inner join
   D_BOOK 
on D_BOOK.ID_BOOK = G.ID_BOOK
where G.GOOD_COUNT < B.BAD_COUNT
;



/* 22. Select readers who never read books of the author 'Dal V.'. */
select R.ID_READER, R.NAME_READER, count(A.ID_AUTHOR)
from D_READER R
    left join READER_BOOK RB
        on R.ID_READER = RB.ID_READER
    left join BOOK_EXAMPLE BE
        on RB.ID_BOOK_EXAMPLE = BE.ID_BOOK_EXAMPLE
    left join D_BOOK B 
        on BE.ID_BOOK = B.ID_BOOK
    left join BOOK_AUTHOR BA
        on BA.ID_BOOK = B.ID_BOOK
    left join D_AUTHOR A
        on A.ID_AUTHOR = BA.ID_AUTHOR and A.NAME_AUTHOR != "Dal V."
group by R.ID_READER, R.NAME_READER
having count(A.ID_AUTHOR) = 0;


/* 23. Determine how many books every reader reads every year. */
select NAME_READER,  YEAR, count(ID_BOOK) 
from (
    select distinct R.NAME_READER,  year(RB.DATE_START) as YEAR, BE.ID_BOOK 
    from D_READER R, READER_BOOK RB, BOOK_EXAMPLE BE 
    where R.ID_READER = 3 and R.ID_READER = RB.ID_READER and BE.ID_BOOK_EXAMPLE = RB.ID_BOOK_EXAMPLE
) Z 
group by NAME_READER,  YEAR
order by NAME_READER, YEAR
;


/* 24. Determine number of books of all scientific styles. */
select NAME_STYLE, count(ID_BOOK) as BOOK_COUNT
from 
D_STYLE S
left join 
D_BOOK B 
on B.ID_STYLE = S.ID_STYLE  
where NAME_STYLE like "Научно-%"
group by NAME_STYLE, S.ID_STYLE
union
select 'all', count(ID_BOOK) 
from 
D_STYLE S
left join 
D_BOOK B 
on B.ID_STYLE = S.ID_STYLE  
where NAME_STYLE like "Научно-%"
;


/* 25. Divide the book into groups: 
  a) thin (less than 100 pages); 
  b) medium (100 to 400 pages); 
  c) thick (400 to 1,000 pages); 
  d) huge (more than 1000 pages). 
*/
select "thin" as GROUPS, "" as BOOK_NAME, "" as PAGE_NUMBER
union
select "", NAME_BOOK, PAGE_NUM 
from  D_BOOK B
where B.PAGE_NUM < 100
union
select "medium", "", ""
union
select "", NAME_BOOK, PAGE_NUM
from  D_BOOK B
where B.PAGE_NUM >= 100 and B.PAGE_NUM < 400
union
select "thick", "", ""
union
select "", NAME_BOOK, PAGE_NUM
from  D_BOOK B
where B.PAGE_NUM >= 400 and B.PAGE_NUM < 1000
union
select "huge", "", ""
union
select "", NAME_BOOK, PAGE_NUM
from  D_BOOK B
where B.PAGE_NUM >= 1000
;



/* 26. Get the names of books that are written more than 3 co-authors. Output the names of the co-authors in the correct order. */
select B.ID_BOOK, B.NAME_BOOK, A.NAME_AUTHOR, BA.POS_AUTHOR
from D_BOOK B, D_AUTHOR A, BOOK_AUTHOR BA
where B.ID_BOOK in( 
    select BI.ID_BOOK
    from D_BOOK BI, D_AUTHOR AI, BOOK_AUTHOR BAI
    where B.ID_BOOK = B.ID_BOOK and BAI.ID_AUTHOR = AI.ID_AUTHOR and BI.ID_BOOK = BAI.ID_BOOK
    group by BI.NAME_BOOK, BI.ID_BOOK
    HAVING count(AI.NAME_AUTHOR)>3
) 
and BA.ID_AUTHOR = A.ID_AUTHOR and B.ID_BOOK = BA.ID_BOOK
order by  B.ID_BOOK, NAME_BOOK, BA.POS_AUTHOR
;


/* 27. etermine the names of readers who are namesakes of one of authors. */
select R.NAME_READER, A.NAME_AUTHOR 
from D_READER R, D_AUTHOR A 
where left(R.NAME_READER, locate(' ', R.NAME_READER)) = left(A.NAME_AUTHOR, locate(' ', A.NAME_AUTHOR));


