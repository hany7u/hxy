CREATE PROCEDURE [dbo].[fly_chuChengLv] @dDate_start varchar(10),@dDate_end varchar(10)
AS
DECLARE @SQL VARCHAR(4000)
BEGIN
create table #FlyTable00
(
	任务号 varchar(50),
	领用原料重量 decimal(26,6),
	产出入库重量 decimal(26,6),
	损耗重量 decimal(26,6),
	出成率 decimal(10,2),
	损耗率 decimal(10,2),
    合理损耗上限 decimal(10,2),
	合理损耗下限 decimal(10,2),
	结果 varchar(10),
	超标准损耗重量 decimal(26,6),
	一次通过率 decimal(10,2),
	标准单价 decimal(20,2),
	损耗金额  decimal(20,2),
	大类 varchar(12)
)
create table #FlyTable01
(
	任务号 varchar(50),
	领用原料重量 decimal(26,6),
	产出入库重量 decimal(26,6),
	损耗重量 decimal(26,6),
	出成率 decimal(10,2),
	损耗率 decimal(10,2),
    合理损耗上限 decimal(10,2),
	合理损耗下限 decimal(10,2),
	结果 varchar(10),
	超标准损耗重量 decimal(26,6),
	一次通过率 decimal(10,2),
	标准单价 decimal(20,2),
	损耗金额  decimal(20,2)
)
create table #FlyTable02
(
	任务号 varchar(50),
	领用原料重量 decimal(26,6),
	产出入库重量 decimal(26,6),
	损耗重量 decimal(26,6),
	出成率 decimal(10,2),
	损耗率 decimal(10,2),
    合理损耗上限 decimal(10,2),
	合理损耗下限 decimal(10,2),
	结果 varchar(10),
	超标准损耗重量 decimal(26,6),
	一次通过率 decimal(10,2),
	标准单价 decimal(20,2),
	损耗金额  decimal(20,2)
)
--查询成品入库数据开始------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set @SQL = '
insert into #FlyTable00 select
rdrecords10.cdefine22 as 任务号,
0 as 领用原料重量,
(case
	when (Inventory.cComUnitCode = ''001'') then rdrecords10.iquantity
	when (Inventory.cComUnitCode <> ''001'') then ((rdrecords10.iquantity * Inventory.iInvWeight)/1000)
end) as 产出入库重量,
0 as 损耗重量,
0 as 出成率,
0 as 损耗率,
0 as 合理损耗上限,
0 as 合理损耗下限,
'''' as 结果,
0 as 超标准损耗重量,
0 as 一次通过率,
0 as 标准单价,
0 as 损耗金额,
Inventory.cInvCCode as 大类
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
--查询成品入库数据结束------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--查询材料出库数据开始------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
insert into #FlyTable01 select
rdrecord11.cDefine1 as 任务号,
(case
	when (Inventory.cComUnitCode = '001') then rdrecords11.iquantity
	when (Inventory.cComUnitCode <> '001') then ((rdrecords11.iquantity * Inventory.iInvWeight)/1000)
end) as 领用原料重量,
0 as 产出入库重量,
0 as 损耗重量,
0 as 出成率,
0 as 损耗率,
(case when (isnull(rdrecord11.cPsPcode,'') = '') then 0.00
     when (isnull(rdrecord11.cPsPcode,'') <> '') then CAST(((1.00 - CAST(isnull(rdrecord11.cdefine9,'1') as decimal(20,2)))*100) as decimal(20,2))
end) as 合理损耗上限,
(case when (isnull(rdrecord11.cPsPcode,'') = '') then 100.00
     when (isnull(rdrecord11.cPsPcode,'') <> '') then CAST(((1.00 - CAST(isnull(rdrecord11.cdefine2,'1') as decimal(20,2)))*100) as decimal(20,2))
end) as 合理损耗下限,
'' as 结果,
0 as 超标准损耗重量,
0 as 一次通过率,
0 as 标准单价,
0 as 损耗金额
from rdrecords11
Left JOIN rdrecord11 ON rdrecords11.ID = rdrecord11.ID
Left JOIN Inventory ON rdrecords11.cInvCode = Inventory.cInvCode
where rdrecord11.cDefine1 in (select 任务号 from #FlyTable00)
--查询材料出库数据结束------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--中间计算开始------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
insert into #FlyTable02 
select 
#FlyTable01.任务号,
sum(#FlyTable01.领用原料重量) as 领用原料重量,
sum(#FlyTable00.产出入库重量) as 产出入库重量,
(sum(#FlyTable01.领用原料重量)-sum(#FlyTable00.产出入库重量)) as 损耗重量,
CAST(((sum(#FlyTable00.产出入库重量)/sum(#FlyTable01.领用原料重量))*100) as decimal(20,2)) as 出成率,
CAST(((1-(sum(#FlyTable00.产出入库重量)/sum(#FlyTable01.领用原料重量)))*100) as decimal(20,2)) as 损耗率,
max(#FlyTable01.合理损耗上限) as 合理损耗上限,
max(#FlyTable01.合理损耗下限) as 合理损耗下限,
'' as 结果,
0 as 超标准损耗重量,
CAST(((sum(case when ((#FlyTable00.大类 LIKE '05%' AND #FlyTable00.大类 NOT LIKE '0596%' AND #FlyTable00.大类 NOT LIKE '0597%' AND #FlyTable00.大类 NOT LIKE '0598%' AND #FlyTable00.大类 NOT LIKE '0599%') OR #FlyTable00.大类 LIKE '07%') then #FlyTable00.产出入库重量 when ((#FlyTable00.大类 NOT LIKE '05%' AND #FlyTable00.大类 NOT LIKE '07%') OR #FlyTable00.大类 LIKE '0596%' OR #FlyTable00.大类 LIKE '0597%' OR #FlyTable00.大类 LIKE '0598%' OR #FlyTable00.大类 LIKE '0599%') then 0 end)/sum(#FlyTable01.领用原料重量))*100) as decimal(20,2)) as 一次通过率,
0 as 标准单价,
0 as 损耗金额
from #FlyTable01 Left JOIN #FlyTable00 ON #FlyTable01.任务号 = #FlyTable00.任务号
group by #FlyTable01.任务号
--中间计算结束------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select 
	任务号,
	领用原料重量,
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

drop table #FlyTable00
drop table #FlyTable01
drop table #FlyTable02

END