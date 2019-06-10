SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


--weiDu 统计维度，输入0表示按照任务号统计，输入1表示按物料、任务单号统计，并按物料汇总
ALTER          PROCEDURE [dbo].[fly_baoCaiSunHaoLv] @weiDu int
	,@dDate_start varchar(100)
	,@dDate_end varchar(100)
	,@renWuHao varchar(100) = null
AS
DECLARE @SQL0 VARCHAR(4000)
DECLARE @SQL1 VARCHAR(4000)

BEGIN
	create table #FlyTable0 (
		任务号 varchar(50)
		)
	create table #FlyTable00 (
		任务号 varchar(50)
		,产品编码 varchar(50)
		,产品名称 varchar(50)
		,规格型号 varchar(50)
		,产出入库数量 decimal(26, 6)
		)
	create table #FlyTable010 (
		任务号 varchar(50)
		,材料编码 varchar(50)
		,材料名称 varchar(50)
		,规格型号 varchar(50)
		,计量单位 varchar(50)
		,合理损耗上限 decimal(26, 6)
		,合理损耗下限 decimal(26, 6)
		,基本用量 decimal(26, 6)
		,基础数量 decimal(26, 6)
		)
	create table #FlyTable01 (
		任务号 varchar(50)
		,材料编码 varchar(50)
		,材料名称 varchar(50)
		,规格型号 varchar(50)
		,计量单位 varchar(50)
		,实际消耗数量 decimal(26, 6)
		)
	create table #base00 (
		任务号 varchar(50)
		,产品编码 varchar(50)
		,产品名称 varchar(50)
		,产品规格 varchar(50)
		,材料编码 varchar(50)
		,材料名称 varchar(50)
		,规格型号 varchar(50)
		,计量单位 varchar(50)
		,产出入库数量 decimal(26, 6)
		,实际消耗数量 decimal(26, 6)
		,合理损耗上限 decimal(26, 6)
		,合理损耗下限 decimal(26, 6)
		,基本用量 decimal(26, 6)
		,基础数量 decimal(26, 6)
		,标准消耗数量 decimal(26, 6)
		,损耗数量 decimal(26, 6)
		,损耗率 decimal(26, 6)
		,结果 varchar(10)
		,超标准损耗数量 decimal(26, 6)
		,基准价格 decimal(26, 6)
		,超标准损耗金额 decimal(26, 6)
		)
	--查询任务号开始
	if (isnull(@weiDu, 0) = 0)
	begin --维度是按任务号统计↓
		if (isnull(@renWuHao, '') <> '')
		begin --如果输入任务号↓
			set @SQL0 = '
				insert into #FlyTable0 select
				rdrecords10.cdefine22 as 任务号
				from rdrecords10
				Left JOIN rdrecord10 ON rdrecords10.ID = rdrecord10.ID
				Left JOIN Inventory ON rdrecords10.cInvCode = Inventory.cInvCode
				where (rdrecords10.cdefine22 is not null and (Inventory.cInvCode like ''05%'' or Inventory.cInvCode like ''07%'')) '
			set @SQL0 = @SQL0 + 'AND (rdrecords10.cdefine22 = ''' + @renWuHao + ''') '
			set @SQL0 = @SQL0 + ' group by rdrecords10.cdefine22'
		end --如果输入任务号↑

		if (isnull(@renWuHao, '') = '')
		begin --如果不输入任务号↓
			set @SQL0 = 'insert into #FlyTable0 select
				rdrecords10.cdefine22 as 任务号
				from rdrecords10
				Left JOIN rdrecord10 ON rdrecords10.ID = rdrecord10.ID
				Left JOIN Inventory ON rdrecords10.cInvCode = Inventory.cInvCode
				where (rdrecords10.cdefine22 is not null and (Inventory.cInvCode like ''05%'' or Inventory.cInvCode like ''07%'')) '
			if (isnull(@dDate_start, '') <> '')
			begin
				set @SQL0 = @SQL0 + 'AND (rdrecord10.dDate >= ''' + @dDate_start + ''') '
			end
			if (isnull(@dDate_end, '') <> '')
			begin
				set @SQL0 = @SQL0 + 'AND (rdrecord10.dDate <= ''' + @dDate_end + ''') '
			end
			set @SQL0 = @SQL0 + ' group by rdrecords10.cdefine22'
		end --如果不输入任务号↑
	end --维度是按任务号统计↑
	if (isnull(@weiDu, 0) <> 0)
	begin --维度是按物料、任务单号统计，并按物料汇总↓
		set @SQL0 = 'insert into #FlyTable0 select
			rdrecords10.cdefine22 as 任务号
			from rdrecords10
			Left JOIN rdrecord10 ON rdrecords10.ID = rdrecord10.ID
			Left JOIN Inventory ON rdrecords10.cInvCode = Inventory.cInvCode
			where (rdrecords10.cdefine22 is not null and (Inventory.cInvCode like ''05%'' or Inventory.cInvCode like ''07%'')) '
		if (isnull(@dDate_start, '') <> '')
		begin
			set @SQL0 = @SQL0 + 'AND (rdrecord10.dDate >= ''' + @dDate_start + ''') '
		end
		if (isnull(@dDate_end, '') <> '')
		begin
			set @SQL0 = @SQL0 + 'AND (rdrecord10.dDate <= ''' + @dDate_end + ''') '
		end
		set @SQL0 = @SQL0 + ' group by rdrecords10.cdefine22'
	end --维度是按物料、任务单号统计，并按物料汇总↑
	exec (@SQL0)
	--查询任务号结束	
	--查询产品入库数据开始-------------------------
	insert into #FlyTable00 select
				rdrecords10.cdefine22 as 任务号,
				Inventory.cInvCode as 产品编码,
				Inventory.cInvName as 产品名称,
				Inventory.cInvStd as 规格型号,
				rdrecords10.iquantity as 产出入库数量
				from rdrecords10
				Left JOIN rdrecord10 ON rdrecords10.ID = rdrecord10.ID
				Left JOIN Inventory ON rdrecords10.cInvCode = Inventory.cInvCode
				where (rdrecords10.cdefine22 in (select 任务号 from #FlyTable0 ) 
							--and rdrecord10.cWhCode <> '59' and rdrecord10.cWhCode <> '23' and rdrecord10.cWhCode <> '07' 
							and ((Inventory.cInvCode like '05%' and Inventory.cInvCode not like '059%') or Inventory.cInvCode like '07%')) 
	--查询产品入库数据结束--------	
	--查询材料出库数据开始--------
	insert into #FlyTable01 select
				rdrecord11.cDefine1 as 任务号,
				Inventory.cInvCode as 材料编码,
				Inventory.cInvName as 材料名称,
				Inventory.cInvStd as 规格型号,
				ComputationUnit.cComUnitName  as 计量单位,
				rdrecords11.iquantity as 实际消耗数量
				from rdrecords11
				Left JOIN rdrecord11 ON rdrecords11.ID = rdrecord11.ID
				Left JOIN Inventory ON rdrecords11.cInvCode = Inventory.cInvCode
				left join ComputationUnit on Inventory.cComUnitCode = ComputationUnit.cComunitCode 
				where Inventory.cInvCCode like '02%' and rdrecord11.cDefine1 in (select 任务号 from #FlyTable0 )
				
	--查询材料出库数据结束---------
	--查询任务单号对应的合理损耗上下限开始
	insert into #FlyTable010 select
				rdrecord11.cDefine1 as 任务号,
				Inventory.cInvCode as 材料编码,
				Inventory.cInvName as 材料名称,
				Inventory.cInvStd as 规格型号,
				ComputationUnit.cComUnitName as 计量单位,
				CAST(isnull(rdrecords11.cdefine23,'0') as decimal(20,6)) as 合理损耗上限,
				CAST(isnull(rdrecords11.cdefine22,'0') as decimal(20,6)) as 合理损耗下限,
				CAST(rdrecords11.cdefine24 as decimal(20,6)) as 基本用量,
				CAST(rdrecords11.cdefine25 as decimal(20,6)) as 基础数量
				from rdrecords11
				Left JOIN rdrecord11 ON rdrecords11.ID = rdrecord11.ID
				Left JOIN Inventory ON rdrecords11.cInvCode = Inventory.cInvCode
				left join ComputationUnit on Inventory.cComUnitCode = ComputationUnit.cComunitCode
				where Inventory.cInvCCode like '02%' and rdrecord11.cDefine1 in (select 任务号 from #FlyTable0 ) and rdrecords11.cdefine25 is not null
				
	--查询任务单号对应的合理损耗上下限结束
	--组装基础表开始
	INSERT INTO #base00 select t0.任务号 as 任务号,T10.产品编码 as 产品编码,T10.产品名称 as 产品名称,T10.规格型号 as 产品规格, T11.材料编码 as 材料编码,T11.材料名称 as 材料名称,T11.规格型号 as 规格型号,T11.计量单位 as 计量单位,
			T1.产出入库数量 as 产出入库数量,T11.实际消耗数量 as 实际消耗数量,T2.合理损耗上限 AS 合理损耗上限,T2.合理损耗下限 AS 合理损耗下限,
			cast(T2.基本用量 as decimal(20,4)) AS 基本用量,cast(T2.基础数量 as decimal(20,4)) AS 基础数量,
			case when cast(T2.基础数量 as decimal(20,6))<>0  then cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,2)) end  as 标准消耗数量,
			case when cast(T2.基础数量 as decimal(20,6))<>0  then cast(T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)) as decimal(20,2)) end  as 损耗数量,
			case when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 then cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量)*100 as decimal(20,2)) end  as 损耗率,
			case 
				when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) >= T2.合理损耗下限 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) <= T2.合理损耗上限
					then '合理'
				when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) > T2.合理损耗上限
					then '浪费'
				when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) < T2.合理损耗下限
					then '节约'
			end as 结果,
			case 
				when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) >= T2.合理损耗下限 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) <= T2.合理损耗上限
					then 0.00
				when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) > T2.合理损耗上限
					then cast((cast(T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)) as decimal(20,6))-cast(T1.产出入库数量*T2.基本用量/T2.基础数量*T2.合理损耗上限 as decimal(20,6))) as decimal(20,2))
				when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) < T2.合理损耗下限
					then cast((cast(T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)) as decimal(20,6))-cast(T1.产出入库数量*T2.基本用量/T2.基础数量*T2.合理损耗下限 as decimal(20,6))) as decimal(20,2))
			end as 超标准损耗数量
		,dj.结存单价 as 基准价格
		,case 
				when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) >= T2.合理损耗下限 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) <= T2.合理损耗上限
					then 0.00
				when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) > T2.合理损耗上限
					then dj.结存单价*cast((cast(T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)) as decimal(20,6))-cast(T1.产出入库数量*T2.基本用量/T2.基础数量*T2.合理损耗上限 as decimal(20,6))) as decimal(20,2))
				when cast(T2.基础数量 as decimal(20,6))<>0 and cast(T11.实际消耗数量 as decimal(20,6))<>0 and cast(((T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)))/T11.实际消耗数量) as decimal(20,6)) < T2.合理损耗下限
					then dj.结存单价*cast((cast(T11.实际消耗数量-cast(T1.产出入库数量*T2.基本用量/T2.基础数量 as decimal(20,6)) as decimal(20,6))-cast(T1.产出入库数量*T2.基本用量/T2.基础数量*T2.合理损耗下限 as decimal(20,6))) as decimal(20,2))
			end as 超标准损耗金额
	from(select DISTINCT #FlyTable0.任务号 AS 任务号 from #FlyTable0) as T0
	left join (select DISTINCT #FlyTable00.任务号 as 任务号,#FlyTable00.产品编码 as 产品编码,#FlyTable00.产品名称 as 产品名称,#FlyTable00.规格型号 as 规格型号
				from #FlyTable00
				
			) as T10 on T0.任务号 = T10.任务号
	left join (select DISTINCT #FlyTable00.任务号 as 任务号,sum(#FlyTable00.产出入库数量) as 产出入库数量 
				from #FlyTable00
				group by #FlyTable00.任务号
			) as T1 on T0.任务号 = T1.任务号
	left join (select DISTINCT #FlyTable01.任务号 as 任务号,#FlyTable01.材料编码 as 材料编码,#FlyTable01.材料名称 as 材料名称,
					#FlyTable01.规格型号 as 规格型号,#FlyTable01.计量单位 as 计量单位,SUM(#FlyTable01.实际消耗数量) as 实际消耗数量 
				FROM #FlyTable01 
				group by #FlyTable01.任务号,#FlyTable01.材料编码,#FlyTable01.材料名称,#FlyTable01.规格型号,#FlyTable01.计量单位
			) as T11 on T0.任务号 = T11.任务号
	LEFT JOIN (select DISTINCT #FlyTable010.任务号 as 任务号,#FlyTable010.材料编码 as 材料编码,
					MAX(#FlyTable010.合理损耗上限) AS 合理损耗上限,
					MAX(#FlyTable010.合理损耗下限) AS 合理损耗下限,					
					MAX(#FlyTable010.基本用量) AS 基本用量,
					MAX(#FlyTable010.基础数量) AS 基础数量
				FROM #FlyTable010
				
				group by #FlyTable010.任务号,#FlyTable010.材料编码 
				
			) as T2 on T11.任务号 = T2.任务号 AND T11.材料编码 = T2.材料编码
	/*关联单价开始*/		
	left join (SELECT t2.仓库编码 AS 仓库编码,t2.存货编码 AS 存货编码,t2.部门编码 AS 部门编码,t2.会计年度 AS 会计年度,t2.会计期间 AS 				会计期间,t2.结存数量 AS 结存数量,t2.结存金额 as 结存金额,CAST(t2.结存金额/t2.结存数量 as DECIMAL(16,6)) as 结存单价
			from (SELECT t.cWhCode AS 仓库编码,t.cInvCode AS 存货编码,t.cDepCode AS 部门编码,max(t.AutoID) AS AutoID
					FROM IA_Summary AS t
					GROUP BY t.cWhCode ,t.cInvCode ,t.cDepCode 
			) as t1
			LEFT JOIN (SELECT t.AutoID as AutoID,t.cWhCode AS 仓库编码,	t.cInvCode AS 存货编码,t.cDepCode AS 部门编码,t.iYear AS 会计年度,t.iMonth AS 会计期间,	t.iNum AS 结存数量,	t.iMoney as 结存金额
					FROM			IA_Summary AS t 
			) as t2 on t1.AutoID = t2.AutoID 
			WHERE t2.结存数量 <>0
			)as dj on T11.材料编码 = dj.存货编码
	/*关联单价结束*/
	where T11.材料编码 is not null
	--组装基础表结束
	SELECT 1 as 汇总标识/*汇总数据，不包含汇总和不大于零的*/
		,'' as 任务号
		,'' as 产品编码
		,'' as 产品名称
		,'' as 产品规格
		,item.材料编码 as 材料编码
		,item.材料名称 as 材料名称
		,item.规格型号 as 规格型号
		,item.计量单位 as 计量单位
		,max(item.基本用量) as 基本用量
		,max(item.基础数量) as 基础数量
		,sum(item.产出入库数量) as 产出入库数量
		,sum(item.实际消耗数量) as 实际消耗数量
		,max(item.合理损耗上限) as 合理损耗上限
		,min(item.合理损耗下限) as 合理损耗下限
		,sum(item.标准消耗数量) as 标准消耗数量
		,sum(item.损耗数量) as 损耗数量
		,cast(sum(item.损耗数量)/sum(item.实际消耗数量) as decimal(20,6)) as 损耗率
		,case when sum(item.实际消耗数量)<>0 and  cast(sum(item.损耗数量)/sum(item.实际消耗数量) as decimal(20,6))>max(item.合理损耗上限) then '浪费' 
			when sum(item.实际消耗数量)<>0 and cast(sum(item.损耗数量)/sum(item.实际消耗数量) as decimal(20,6))<min(item.合理损耗下限) then '节约'
			else '合理'
		end as 结果
		,case when sum(item.实际消耗数量)<>0 and cast(sum(item.损耗数量)/sum(item.实际消耗数量) as decimal(20,6))>max(item.合理损耗上限) 
				then sum(item.实际消耗数量)- sum(item.标准消耗数量)
			when sum(item.实际消耗数量)<>0 and cast(sum(item.损耗数量)/sum(item.实际消耗数量) as decimal(20,6))<min(item.合理损耗下限) 
				then sum(item.标准消耗数量)- sum(item.实际消耗数量)
			else 0
		end as 超标准损耗数量
		,avg(item.基准价格) as 基准价格
		,sum(item.超标准损耗金额) as 超标准损耗金额 
		from #base00 as item
		--where sum(item.实际消耗数量) <> 0
		group by item.材料编码 ,item.材料名称,item.规格型号,item.计量单位
		having sum(item.实际消耗数量) > 0
union ALL		
		SELECT 0 as 汇总标识/*明细数据*/
		,item.任务号 as 任务号
		,item.产品编码 as 产品编码
		,item.产品名称 as 产品名称
		,item.产品规格 as 产品规格
		,item.材料编码 as 材料编码
		,item.材料名称 as 材料名称
		,item.规格型号 as 规格型号
		,item.计量单位 as 计量单位
		,item.基本用量 as 基本用量
		,item.基础数量 as 基础数量
		,item.产出入库数量 as 产出入库数量
		,item.实际消耗数量 as 实际消耗数量
		,item.合理损耗上限 as 合理损耗上限
		,item.合理损耗下限 as 合理损耗下限
		,item.标准消耗数量 as 标准消耗数量
		,item.损耗数量 as 损耗数量
		,item.损耗率 as 损耗率
		,item.结果 as 结果
		,item.超标准损耗数量 as 超标准损耗数量
		,item.基准价格 as 基准价格
		,item.超标准损耗金额 as 超标准损耗金额 
		from #base00 as item
		


	drop table #FlyTable0
	drop table #FlyTable00
	drop table #FlyTable01
	drop table #FlyTable010
	DROP table #base00

END

GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS OFF 
GO

