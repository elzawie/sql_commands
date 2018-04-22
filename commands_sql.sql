/* List departments in each row */
select
   department
from
   staff;

/* List each department name once */
select distinct
  department
from
  staff;


/* Convert the names of departments to upper case */
select distinct
   upper(department)
from
   staff;

/* Convert the names of departments to lower case */
select distinct
  lower(department)
from
  staff;



/* Use alias to rename concatenated column */
select
   job_title || '-' || department  title_dept
from
   staff;



/*  ... and now verify length is shorter when leading and trailing spaces are removed */
select
   length(trim('   Software Engineer   '));




/* Create a new boolean column indicating if a staff person has the term Assistant
  anywhere in their title.  */
select
   job_title, (job_title like '%Assistant%') is_asst
from
   staff;



/* Change Assistant to Asst in job title */

select
    job_title, overlay(job_title placing 'Asst. ' from position('Assistant' in job_title) for 10)
from
    staff
where
    job_title like '%Assistant%';




/* Select a list of job titles that include Assistant II or IV*/
/* | is the regular expression OR operator */
select distinct
    job_title
from
    staff
where
   job_title similar to '%Assistant%(II|IV)';



/* Select a list of job titles that begin with E, P, or S */
/* |[] are used to list characters that can match */
select distinct
    job_title
from
    staff
where
   job_title similar to '[EPS]%';
   
   
   
/* Trunc can be used to truncate to a number of decimal places */
select
   department, avg(salary), round(avg(salary), 2), trunc(avg(salary), 2)
from
   staff
group by
    department;

    
    
/* Include department's average salary in each row with staff */
/* Use an alias on table names so that one table can be queried in */
/* subqueries and top level queries */
select
  s1.last_name,
  s1.salary,
  s1.department,
  (select round(avg(salary)) from staff s2 where s1.department = s2.department) dept_avg
from
  staff s1;

  

/* Select columns from a subquery instead of a table */
/* Find the average of executive salaries, defined as salaries > 100,000 */
select
   department,
   round(avg(salary))
from
    (select
         s2.department,
         s2.salary
     from
         staff s2
     where
         salary > 100000) s1
group by
    department;

    
  

/* Select the department that has the employee with the highest salary */
select
  s1.department
from
  staff s1
where
  (select max(salary) from staff s2) = salary;


  
/* Create a view to minimize the amount of typing and reduce the risk of making a mistake */
create view staff_div_reg as
   select
     s.*, cd.company_division, cr.company_region
   from
     staff s
   left join
     company_divisions cd
   on
     s.department = cd.department
   left join
     company_regions cr
   on
      s.region_id = cr.region_id;
      
      
      
/* Now, add in gender to break down even further */
/* Get employee counts by division and by region */
select
   company_division, company_region, gender, count(*)
from
   staff_div_reg
group by
   grouping sets (company_division, company_region, gender)
order by
   company_region, company_division, gender;
   


/* Use rollup operation on the group by clause to create hierarchical sums */
select
   company_region, country, count(*)
from
   staff_div_reg
group by
   rollup (country, company_region)
order by
   country, company_region


   
/* Use cube operation on the group by clause to create all possible combination of sets of grouping columns */
select
   company_division, company_region,  count(*)
from
   staff_div_reg
group by
   cube (company_division, company_region);
   

 
/* Use fetch first with order by to select top 5 divisions by staff count */
select
   company_division, count(*)
from
   staff_div_reg
group by
   company_division
order by
   count(*) desc
fetch first
   5 rows only;


   
/* Use a windowing operation with a different aggregate function and different grouping */
select
   company_region,
   last_name,
   salary,
   min(salary) over (partition by company_region) -- Can be: avg, max, rank()
from
   staff_div_reg;


   /* Select a set of attributes grouped by department, include the first value by department in each row */
select
   department,
   last_name,
   salary,
   first_value(salary) over (partition by department order by salary desc)
from
   staff;
   
   
/* Window functions can be used to add ranked row numbers */
select
   company_division,
   last_name,
   salary,
   row_number()  over (partition by company_division order by salary asc)
from
   staff_div_reg;
  

  
/* Order results and include the relative rank by row */
select
   department,
   last_name,
   salary,
   rank() over (partition by department order by salary desc)
from
   staff;
   
   
 
/*  Use lag to reference rows behind */
select
   department,
   salary,
   lag(salary) over (partition by department order by salary desc)
from
   staff

   
   
/* Use lead to reference rows ahead */
select
   department,
   salary,
   lead(salary) over (partition by department order by salary desc)
from
   staff

   
   
/* Use ntiles to assign "buckets" to rows */
/* Include quartiles in list of salaries by department */
select
   department,
   salary,
   ntile(4) over (partition by department order by salary desc) as quartile
from
   staff;



   
 

