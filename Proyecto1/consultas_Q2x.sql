/*Q21 Modos de envio y orden de prioridad */
/*Probar $1 =  'MAIL'*/
/*Probar $2 =  'SHIP'*/
/*Probar $3 =  '1994-01-01'*/

select
  l_shipmode,
  sum(case
    when o_orderpriority = '1-URGENT'
      or o_orderpriority = '2-HIGH'
      then 1
    else 0
  end) as high_line_count,
  sum(case
    when o_orderpriority <> '1-URGENT'
      and o_orderpriority <> '2-HIGH'
      then 1
    else 0
  end) as low_line_count
from
  orders,
  lineitem
where
  o_orderkey = l_orderkey
  and l_shipmode in ('MAIL',  'SHIP')
  and l_commitdate < l_receiptdate
  and l_shipdate < l_commitdate
  and l_receiptdate >= '1994-01-01'
  and l_receiptdate < '1994-01-01' + interval '1 year'
group by
  l_shipmode
order by
  l_shipmode;

/* Q22 Relacion parte/proveedor */
/*Probar $1 =  'Brand#45'*/
/*Probar $2 =  'MEDIUM POLISHED%'*/
/*Probar $3 =  49*/
/*Probar $4 =  14*/
/*Probar $5 =  23*/
/*Probar $6 =  45*/
/*Probar $7 =  19*/
/*Probar $8 =  3*/
/*Probar $9 =  36*/
/*Probar $10 =  9*/

select
  p_brand,
  p_type,
  p_size,
  count(distinct ps_suppkey) as supplier_cnt
from
  partsupp,
  part
where
  p_partkey = ps_partkey
  and p_brand <> 'Brand#45'
  and p_type not like 'MEDIUM POLISHED%'
  and p_size in (49, 14, 23, 45, 19, 3, 36, 9)
  and ps_suppkey not in (
    select
      s_suppkey
    from
      supplier
    where
      s_comment like '%Customer%Complaints%'
  )
group by
  p_brand,
  p_type,
  p_size
order by
  supplier_cnt desc,
  p_brand,
  p_type,
  p_size;

/* Q23 Oportunidad de ventas globales*/
/*Probar $1 =  '13'*/
/*Probar $2 =  '31'*/
/*Probar $3 =  '23'*/
/*Probar $4 =  '29'*/
/*Probar $5 =  '30'*/
/*Probar $6 =  '18'*/
/*Probar $7 =  '17'*/

select
  cntrycode,
  count(*) as numcust,
  sum(c_acctbal) as totacctbal
from
  (
    select
      substring(c_phone from 1 for 2) as cntrycode,
      c_acctbal
    from
      customer
    where
      substring(c_phone from 1 for 2) in
        ('13', '31', '23', '29', '30', '18', '17')
      and c_acctbal > (
        select
          avg(c_acctbal)
        from
          customer
        where
          c_acctbal > 0.00
          and substring(c_phone from 1 for 2) in
            ('13', '31', '23', '29', '30', '18', '17')
      )
      and not exists (
        select
          *
        from
          orders
        where
          o_custkey = c_custkey
      )
  ) as custsale
group by
  cntrycode
order by
  cntrycode;
