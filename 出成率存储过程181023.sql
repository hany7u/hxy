
ALTER     PROCEDURE [dbo].[fly_chuChengLv] @dDate_start varchar(10),@dDate_end varchar(10)
AS
DECLARE @SQL VARCHAR(4000)
BEGIN
create table #FlyTable0
(
	任务号 varchar(50)
)
create table #FlyTable00
(
	任务号 varchar(50),
	产品编码 varchar(50),
	产品名称 varchar(50),
	产品规格 varchar(50),
	产出入库重量 decimal(26,6),
	一次通过重量 decimal(26,6)
)
create table #FlyTable01
(
	任务号 varchar(50),
	领用原料重量 decimal(26,6)
)
create table #FlyTable011
(
	任务号 varchar(50),
	合理损耗上限 decimal(20,6),
	合理损耗下限 decimal(20,6)
)

create table #FlyTable02
(
	任务号 varchar(50),产品编码 varchar(50),产品名称 varchar(50),产品规格 varchar(50),
	领用原料重量 decimal(26,6),
	明细入库重量 decimal(26,6),
	产出入库重量 decimal(26,6),
	一次通过重量 decimal(26,6),
	损耗重量 decimal(26,6),
	出成率 decimal(20,6),
	损耗率 decimal(20,6),
	合理损耗上限 decimal(20,6),
	合理损耗下限 decimal(20,6),
	结果 varchar(10),
	超标准损耗重量 decimal(26,6),
	一次通过率 decimal(20,6),
	标准单价 decimal(20,2),
	损耗金额  decimal(20,2)
)
--查询任务号开始------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set @SQL = '
insert into #FlyTable0 select
rdrecords10.cdefine22 as 任务号
from rdrecords10
Left JOIN rdrecord10 ON rdrecords10.ID = rdrecord10.ID
Left JOIN Inventory ON rdrecords10.cInvCode = Inventory.cInvCode
where (rdrecords10.cdefine22 is not null and (Inventory.cInvCode like ''05%'' or Inventory.cInvCode like ''07%'')) '
if(isnull(@dDate_start,'')<>'')
begin
set @SQL = @SQL + 'AND (rdrecord10.dDate >= '''+@dDate_start+''') '
end
if(isnull(@dDate_end,'')<>'')
begin
set @SQL = @SQL + 'AND (rdrecord10.dDate <= '''+@dDate_end+''') '
end
exec (@SQL)
--查询任务号结束-
--查询成品入库数据开始------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
insert into #FlyTable00 select
rdrecords10.cdefine22 as 任务号,Inventory.cInvCode as 产品编码,
				Inventory.cInvName as 产品名称,
				Inventory.cInvStd as 产品规格,
(case
	when (Inventory.cComUnitCode = '001') then rdrecords10.iquantity
	when (Inventory.cComUnitCode <> '001') then ((rdrecords10.iquantity * Inventory.iInvWeight)/1000)
end) as 产出入库重量,
(case
	when (Inventory.cComUnitCode = '001' and ((Inventory.cInvCCode LIKE '05%' AND Inventory.cInvCCode NOT LIKE '0596%' AND Inventory.cInvCCode NOT LIKE '0597%' AND Inventory.cInvCCode NOT LIKE '0598%' AND Inventory.cInvCCode NOT LIKE '0599%') OR Inventory.cInvCCode LIKE '07%')) then rdrecords10.iquantity
	when (Inventory.cComUnitCode <> '001'and ((Inventory.cInvCCode LIKE '05%' AND Inventory.cInvCCode NOT LIKE '0596%' AND Inventory.cInvCCode NOT LIKE '0597%' AND Inventory.cInvCCode NOT LIKE '0598%' AND Inventory.cInvCCode NOT LIKE '0599%') OR Inventory.cInvCCode LIKE '07%')) then ((rdrecords10.iquantity * Inventory.iInvWeight)/1000)
end) as 一次通过重量
from rdrecords10
Left JOIN rdrecord10 ON rdrecords10.ID = rdrecord10.ID
Left JOIN Inventory ON rdrecords10.cInvCode = Inventory.cInvCode
where (rdrecords10.cdefine22 in (select 任务号 from #FlyTable0) and (Inventory.cInvCode like '05%' or Inventory.cInvCode like '07%')) 
--查询成品入库数据结束------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--查询材料出库数据开始------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
insert into #FlyTable01 select
				rdrecord11.cDefine1 as 任务号,
				
(case
	when (Inventory.cComUnitCode = '001') then rdrecords11.iquantity
	when (Inventory.cComUnitCode <> '001') then ((rdrecords11.iquantity * Inventory.iInvWeight)/1000)
end) as 领用原料重量
from rdrecords11
Left JOIN rdrecord11 ON rdrecords11.ID = rdrecord11.ID
Left JOIN Inventory ON rdrecords11.cInvCode = Inventory.cInvCode
where rdrecord11.cDefine1 in (select 任务号 from #FlyTable0) AND Inventory.cInvCCode NOT LIKE '02%'/*and isnull(rdrecord11.cPsPcode,'') <> ''*/
--查询材料出库数据结束------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--计算任务号对应合理损耗率开始
insert into #FlyTable011 select
rdrecord11.cDefine1 as 任务号,
CAST((1.00 - CAST(isnull(rdrecord11.cdefine9,'1') as decimal(20,6)))*100 as decimal(20,6)) as 合理损耗上限,
CAST((1.00 - CAST(isnull(rdrecord11.cdefine2,'1') as decimal(20,6)))*100 as decimal(20,6)) as 合理损耗下限
from rdrecords11
Left JOIN rdrecord11 ON rdrecords11.ID = rdrecord11.ID
where rdrecord11.cDefine1 in (select 任务号 from #FlyTable0) and isnull(rdrecord11.cPsPcode,'') <> ''
--计算任务号对应合理损耗率结束
--中间计算开始------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
insert into #FlyTable02 
SELECT LT0.任务号 as 任务号,LT00.产品编码 as 产品编码,LT00.产品名称 as 产品名称,LT00.产品规格 as 产品规格,LT1.领用原料重量 as 领用原料重量,LT00.明细入库重量 as 明细入库重量,LT0.产出入库重量 as 产出入库重量,LT0.一次通过重量 as 一次通过重量,
			(LT1.领用原料重量-LT0.产出入库重量) as 损耗重量, CAST((cast(LT0.产出入库重量/LT1.领用原料重量 as decimal(20,6))*100) as decimal(20,2)) as 出成率,
			isnull(CAST((1-CAST(((LT0.产出入库重量/LT1.领用原料重量)) as decimal(20,6)))*100 as decimal(20,2)),0) as 损耗率,
			isnull(LT2.合理损耗上限,0) as 合理损耗上限,isnull(LT2.合理损耗下限,0) as 合理损耗下限,
			'' as 结果,0 as 超标准损耗重量,CAST(((LT0.一次通过重量/LT1.领用原料重量)*100) as decimal(20,2)) as 一次通过率,
		0 as 标准单价,
		0 as 损耗金额
FROM (
select #FlyTable00.任务号 as 任务号,--#FlyTable00.产品编码 as 产品编码,#FlyTable00.产品名称 as 产品名称,#FlyTable00.产品规格 as 产品规格,
--sum(#FlyTable00.产出入库重量)  as 明细入库重量,
sum(#FlyTable00.产出入库重量)  as 产出入库重量,
sum(#FlyTable00.一次通过重量)  as 一次通过重量
from #FlyTable00 
group by #FlyTable00.任务号--,#FlyTable00.产品编码 ,#FlyTable00.产品名称,#FlyTable00.产品规格
) AS LT0
LEFT JOIN(
select #FlyTable00.任务号 as 任务号,#FlyTable00.产品编码 as 产品编码,#FlyTable00.产品名称 as 产品名称,#FlyTable00.产品规格 as 产品规格,
sum(#FlyTable00.产出入库重量)  as 明细入库重量--,
--sum(#FlyTable00.产出入库重量)  as 产出入库重量,
--sum(#FlyTable00.一次通过重量)  as 一次通过重量
from #FlyTable00 
group by #FlyTable00.任务号,#FlyTable00.产品编码 ,#FlyTable00.产品名称,#FlyTable00.产品规格
) AS LT00 ON LT0.任务号 = LT00.任务号
left join (
select #FlyTable01.任务号 as 任务号,
sum(#FlyTable01.领用原料重量) as 领用原料重量
from #FlyTable01 
group by #FlyTable01.任务号) AS LT1 ON LT0.任务号 = LT1.任务号
left join (
select #FlyTable011.任务号 as 任务号,
max(#FlyTable011.合理损耗上限) as 合理损耗上限,
max(#FlyTable011.合理损耗下限) as 合理损耗下限
from #FlyTable011
group by #FlyTable011.任务号) AS LT2 ON LT0.任务号 = LT2.任务号
where LT1.领用原料重量 <> 0


--中间计算结束------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select distinct
	任务号,
产品编码,产品名称,产品规格,
	领用原料重量,
	明细入库重量,
	产出入库重量,
	损耗重量,
	出成率,
	损耗率,
  合理损耗上限,
	合理损耗下限,
	(case
		when (损耗率 <= 合理损耗上限 AND 损耗率 >= 合理损耗下限) then '合理'
		when (损耗率 < 合理损耗下限) then '节约'
		when (损耗率 > 合理损耗上限) then '浪费'
	end) as 结果,
	(case
		when (损耗率 <= 合理损耗上限 AND 损耗率 >= 合理损耗下限) then 0
		when (损耗率 < 合理损耗下限) then (损耗重量-(产出入库重量*(合理损耗下限/100)))
		when (损耗率 > 合理损耗上限) then (损耗重量-(产出入库重量*(合理损耗上限/100)))
	end) as 超标准损耗重量,
	一次通过率,
	标准单价,
	(case
		when (损耗率 <= 合理损耗上限 AND 损耗率 >= 合理损耗下限) then 0
		when (损耗率 < 合理损耗下限) then ((损耗重量-(产出入库重量*(合理损耗下限/100)))*标准单价)
		when (损耗率 > 合理损耗上限) then ((损耗重量-(产出入库重量*(合理损耗上限/100)))*标准单价)
	end) as 损耗金额
from #FlyTable02
where 领用原料重量 is not NULL
drop table #FlyTable0
drop table #FlyTable00
drop table #FlyTable01
drop table #FlyTable011
drop table #FlyTable02

END


