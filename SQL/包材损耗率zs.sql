SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


--weiDu ͳ��ά�ȣ�����0��ʾ���������ͳ�ƣ�����1��ʾ�����ϡ����񵥺�ͳ�ƣ��������ϻ���
ALTER          PROCEDURE [dbo].[fly_baoCaiSunHaoLv] @weiDu int
	,@dDate_start varchar(100)
	,@dDate_end varchar(100)
	,@renWuHao varchar(100) = null
AS
DECLARE @SQL0 VARCHAR(4000)
DECLARE @SQL1 VARCHAR(4000)

BEGIN
	create table #FlyTable0 (
		����� varchar(50)
		)
	create table #FlyTable00 (
		����� varchar(50)
		,��Ʒ���� varchar(50)
		,��Ʒ���� varchar(50)
		,����ͺ� varchar(50)
		,����������� decimal(26, 6)
		)
	create table #FlyTable010 (
		����� varchar(50)
		,���ϱ��� varchar(50)
		,�������� varchar(50)
		,����ͺ� varchar(50)
		,������λ varchar(50)
		,����������� decimal(26, 6)
		,����������� decimal(26, 6)
		,�������� decimal(26, 6)
		,�������� decimal(26, 6)
		)
	create table #FlyTable01 (
		����� varchar(50)
		,���ϱ��� varchar(50)
		,�������� varchar(50)
		,����ͺ� varchar(50)
		,������λ varchar(50)
		,ʵ���������� decimal(26, 6)
		)
	--��ѯ����ſ�ʼ
	if (isnull(@weiDu, 0) = 0)
	begin --ά���ǰ������ͳ�ơ�
		if (isnull(@renWuHao, '') <> '')
		begin --�����������š�
			set @SQL0 = '
				insert into #FlyTable0 select
				rdrecords10.cdefine22 as �����
				from rdrecords10
				Left JOIN rdrecord10 ON rdrecords10.ID = rdrecord10.ID
				Left JOIN Inventory ON rdrecords10.cInvCode = Inventory.cInvCode
				where (rdrecords10.cdefine22 is not null and (Inventory.cInvCode like ''05%'' or Inventory.cInvCode like ''07%'')) '
			set @SQL0 = @SQL0 + 'AND (rdrecords10.cdefine22 = ''' + @renWuHao + ''') '
			set @SQL0 = @SQL0 + ' group by rdrecords10.cdefine22'
		end --�����������š�

		if (isnull(@renWuHao, '') = '')
		begin --�������������š�
			set @SQL0 = 'insert into #FlyTable0 select
				rdrecords10.cdefine22 as �����
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
		end --�������������š�
	end --ά���ǰ������ͳ�ơ�
	if (isnull(@weiDu, 0) <> 0)
	begin --ά���ǰ����ϡ����񵥺�ͳ�ƣ��������ϻ��ܡ�
		set @SQL0 = 'insert into #FlyTable0 select
			rdrecords10.cdefine22 as �����
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
	end --ά���ǰ����ϡ����񵥺�ͳ�ƣ��������ϻ��ܡ�
	exec (@SQL0)
	--��ѯ����Ž���	
	--��ѯ��Ʒ������ݿ�ʼ-------------------------
	insert into #FlyTable00 select
				rdrecords10.cdefine22 as �����,
				Inventory.cInvCode as ��Ʒ����,
				Inventory.cInvName as ��Ʒ����,
				Inventory.cInvStd as ����ͺ�,
				rdrecords10.iquantity as �����������
				from rdrecords10
				Left JOIN rdrecord10 ON rdrecords10.ID = rdrecord10.ID
				Left JOIN Inventory ON rdrecords10.cInvCode = Inventory.cInvCode
				where (rdrecords10.cdefine22 in (select ����� from #FlyTable0 ) 
							--and rdrecord10.cWhCode <> '59' and rdrecord10.cWhCode <> '23' and rdrecord10.cWhCode <> '07' 
							and ((Inventory.cInvCode like '05%' and Inventory.cInvCode not like '059%') or Inventory.cInvCode like '07%')) 
	--��ѯ��Ʒ������ݽ���--------	
	--��ѯ���ϳ������ݿ�ʼ--------
	insert into #FlyTable01 select
				rdrecord11.cDefine1 as �����,
				Inventory.cInvCode as ���ϱ���,
				Inventory.cInvName as ��������,
				Inventory.cInvStd as ����ͺ�,
				Inventory.cComUnitCode as ������λ,
				rdrecords11.iquantity as ʵ����������
				from rdrecords11
				Left JOIN rdrecord11 ON rdrecords11.ID = rdrecord11.ID
				Left JOIN Inventory ON rdrecords11.cInvCode = Inventory.cInvCode
				where Inventory.cInvCCode like '02%' and rdrecord11.cDefine1 in (select ����� from #FlyTable0 )
				
	--��ѯ���ϳ������ݽ���---------
	--��ѯ���񵥺Ŷ�Ӧ�ĺ�����������޿�ʼ
	insert into #FlyTable010 select
				rdrecord11.cDefine1 as �����,
				Inventory.cInvCode as ���ϱ���,
				Inventory.cInvName as ��������,
				Inventory.cInvStd as ����ͺ�,
				Inventory.cComUnitCode as ������λ,
				CAST(isnull(rdrecords11.cdefine23,'0') as decimal(20,6)) as �����������,
				CAST(isnull(rdrecords11.cdefine22,'0') as decimal(20,6)) as �����������,
				CAST(rdrecords11.cdefine24 as decimal(20,6)) as ��������,
				CAST(rdrecords11.cdefine25 as decimal(20,6)) as ��������
				from rdrecords11
				Left JOIN rdrecord11 ON rdrecords11.ID = rdrecord11.ID
				Left JOIN Inventory ON rdrecords11.cInvCode = Inventory.cInvCode
				where Inventory.cInvCCode like '02%' and rdrecord11.cDefine1 in (select ����� from #FlyTable0 ) and rdrecords11.cdefine25 is not null
				
	--��ѯ���񵥺Ŷ�Ӧ�ĺ�����������޽���
	--��ѯ�����ʼ
	select t0.����� as �����,T10.��Ʒ���� as ��Ʒ����,T10.��Ʒ���� as ��Ʒ����,T10.����ͺ� as ��Ʒ���, T11.���ϱ��� as ���ϱ���,T11.�������� as ��������,T11.����ͺ� as ����ͺ�,T11.������λ as ������λ,
			T1.����������� as �����������,T11.ʵ���������� as ʵ����������,T2.����������� AS �����������,T2.����������� AS �����������,
			cast(T2.�������� as decimal(20,4)) AS ��������,cast(T2.�������� as decimal(20,4)) AS ��������,
			case when cast(T2.�������� as decimal(20,6))<>0  then cast(T1.�����������*T2.��������/T2.�������� as decimal(20,2)) end  as ��׼��������,
			case when cast(T2.�������� as decimal(20,6))<>0  then cast(T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)) as decimal(20,2)) end  as �������,
			case when cast(T2.�������� as decimal(20,6))<>0 and cast(T11.ʵ���������� as decimal(20,6))<>0 then cast(((T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)))/T11.ʵ����������)*100 as decimal(20,2)) end  as �����,
			case 
				when cast(T2.�������� as decimal(20,6))<>0 and cast(T11.ʵ���������� as decimal(20,6))<>0 and cast(((T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)))/T11.ʵ����������) as decimal(20,6)) >= T2.����������� and cast(((T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)))/T11.ʵ����������) as decimal(20,6)) <= T2.�����������
					then '����'
				when cast(T2.�������� as decimal(20,6))<>0 and cast(T11.ʵ���������� as decimal(20,6))<>0 and cast(((T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)))/T11.ʵ����������) as decimal(20,6)) > T2.�����������
					then '�˷�'
				when cast(T2.�������� as decimal(20,6))<>0 and cast(T11.ʵ���������� as decimal(20,6))<>0 and cast(((T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)))/T11.ʵ����������) as decimal(20,6)) < T2.�����������
					then '��Լ'
			end as ���,
			case 
				when cast(T2.�������� as decimal(20,6))<>0 and cast(T11.ʵ���������� as decimal(20,6))<>0 and cast(((T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)))/T11.ʵ����������) as decimal(20,6)) >= T2.����������� and cast(((T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)))/T11.ʵ����������) as decimal(20,6)) <= T2.�����������
					then 0.00
				when cast(T2.�������� as decimal(20,6))<>0 and cast(T11.ʵ���������� as decimal(20,6))<>0 and cast(((T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)))/T11.ʵ����������) as decimal(20,6)) > T2.�����������
					then cast((cast(T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)) as decimal(20,6))-cast(T1.�����������*T2.��������/T2.��������*T2.����������� as decimal(20,6))) as decimal(20,2))
				when cast(T2.�������� as decimal(20,6))<>0 and cast(T11.ʵ���������� as decimal(20,6))<>0 and cast(((T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)))/T11.ʵ����������) as decimal(20,6)) < T2.�����������
					then cast((cast(T11.ʵ����������-cast(T1.�����������*T2.��������/T2.�������� as decimal(20,6)) as decimal(20,6))-cast(T1.�����������*T2.��������/T2.��������*T2.����������� as decimal(20,6))) as decimal(20,2))
			end as ����׼�������
		,'-' as ��׼�۸�
		,'-' as ����׼��Ľ��
	from(select DISTINCT #FlyTable0.����� AS ����� from #FlyTable0) as T0
	left join (select DISTINCT #FlyTable00.����� as �����,#FlyTable00.��Ʒ���� as ��Ʒ����,#FlyTable00.��Ʒ���� as ��Ʒ����,#FlyTable00.����ͺ� as ����ͺ�
				from #FlyTable00
				
			) as T10 on T0.����� = T10.�����
	left join (select DISTINCT #FlyTable00.����� as �����,sum(#FlyTable00.�����������) as ����������� 
				from #FlyTable00
				group by #FlyTable00.�����
			) as T1 on T0.����� = T1.�����
	left join (select DISTINCT #FlyTable01.����� as �����,#FlyTable01.���ϱ��� as ���ϱ���,#FlyTable01.�������� as ��������,
					#FlyTable01.����ͺ� as ����ͺ�,#FlyTable01.������λ as ������λ,SUM(#FlyTable01.ʵ����������) as ʵ���������� 
				FROM #FlyTable01 
				group by #FlyTable01.�����,#FlyTable01.���ϱ���,#FlyTable01.��������,#FlyTable01.����ͺ�,#FlyTable01.������λ
			) as T11 on T0.����� = T11.�����
	LEFT JOIN (select DISTINCT #FlyTable010.����� as �����,#FlyTable010.���ϱ��� as ���ϱ���,
					MAX(#FlyTable010.�����������) AS �����������,
					MAX(#FlyTable010.�����������) AS �����������,					
					MAX(#FlyTable010.��������) AS ��������,
					MAX(#FlyTable010.��������) AS ��������
				FROM #FlyTable010
				
				group by #FlyTable010.�����,#FlyTable010.���ϱ��� 
				
			) as T2 on T11.����� = T2.����� AND T11.���ϱ��� = T2.���ϱ��� 
	where T11.���ϱ��� is not null
	--��ѯ��������
	drop table #FlyTable0
	drop table #FlyTable00
	drop table #FlyTable01
	drop table #FlyTable010
END



GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

