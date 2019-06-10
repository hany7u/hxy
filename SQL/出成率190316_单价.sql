SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO


ALTER       PROCEDURE [dbo].[fly_chuChengLv] @dDate_start varchar(10),@dDate_end varchar(10)
AS
DECLARE @SQL VARCHAR(4000)
BEGIN
create table #FlyTable0
(
	����� varchar(50)
)
create table #FlyTable00
(
	����� varchar(50),
	��Ʒ���� varchar(50),
	��Ʒ���� varchar(50),
	��Ʒ��� varchar(50),
	����������� decimal(26,6),
	һ��ͨ������ decimal(26,6)
)
create table #FlyTable01
(
	����� varchar(50),
	����ԭ������ decimal(26,6)
)
create table #FlyTable011
(
	����� varchar(50),
	����������� decimal(20,6),
	����������� decimal(20,6)
)

create table #FlyTable02
(
	����� varchar(50),��Ʒ���� varchar(50),��Ʒ���� varchar(50),��Ʒ��� varchar(50),
	����ԭ������ decimal(26,6),
	��ϸ������� decimal(26,6),
	����������� decimal(26,6),
	һ��ͨ������ decimal(26,6),
	������� decimal(26,6),
	������ decimal(20,6),
	����� decimal(20,6),
	����������� decimal(20,6),
	����������� decimal(20,6),
	��� varchar(10),
	����׼������� decimal(26,6),
	һ��ͨ���� decimal(20,6),
	��׼���� decimal(20,6),
	��Ľ��  decimal(20,2)
)
--��ѯ����ſ�ʼ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set @SQL = '
insert into #FlyTable0 select
rdrecords10.cdefine22 as �����
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
--��ѯ����Ž���-
--��ѯ��Ʒ������ݿ�ʼ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
insert into #FlyTable00 select
rdrecords10.cdefine22 as �����,Inventory.cInvCode as ��Ʒ����,
				Inventory.cInvName as ��Ʒ����,
				Inventory.cInvStd as ��Ʒ���,
(case
	when (Inventory.cComUnitCode = '001') then rdrecords10.iquantity
	when (Inventory.cComUnitCode <> '001') then ((rdrecords10.iquantity * Inventory.iInvWeight)/1000)
end) as �����������,
(case
	when (Inventory.cComUnitCode = '001' and ((Inventory.cInvCCode LIKE '05%' AND Inventory.cInvCCode NOT LIKE '0596%' AND Inventory.cInvCCode NOT LIKE '0597%' AND Inventory.cInvCCode NOT LIKE '0598%' AND Inventory.cInvCCode NOT LIKE '0599%') OR Inventory.cInvCCode LIKE '07%')) then rdrecords10.iquantity
	when (Inventory.cComUnitCode <> '001'and ((Inventory.cInvCCode LIKE '05%' AND Inventory.cInvCCode NOT LIKE '0596%' AND Inventory.cInvCCode NOT LIKE '0597%' AND Inventory.cInvCCode NOT LIKE '0598%' AND Inventory.cInvCCode NOT LIKE '0599%') OR Inventory.cInvCCode LIKE '07%')) then ((rdrecords10.iquantity * Inventory.iInvWeight)/1000)
end) as һ��ͨ������
from rdrecords10
Left JOIN rdrecord10 ON rdrecords10.ID = rdrecord10.ID
Left JOIN Inventory ON rdrecords10.cInvCode = Inventory.cInvCode
where (rdrecords10.cdefine22 in (select ����� from #FlyTable0) and (Inventory.cInvCode like '05%' or Inventory.cInvCode like '07%')) 
--��ѯ��Ʒ������ݽ���------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--��ѯ���ϳ������ݿ�ʼ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
insert into #FlyTable01 select
				rdrecord11.cDefine1 as �����,
				
(case
	when (Inventory.cComUnitCode = '001') then rdrecords11.iquantity
	when (Inventory.cComUnitCode <> '001') then ((rdrecords11.iquantity * Inventory.iInvWeight)/1000)
end) as ����ԭ������
from rdrecords11
Left JOIN rdrecord11 ON rdrecords11.ID = rdrecord11.ID
Left JOIN Inventory ON rdrecords11.cInvCode = Inventory.cInvCode
where rdrecord11.cDefine1 in (select ����� from #FlyTable0) AND Inventory.cInvCCode NOT LIKE '02%'/*and isnull(rdrecord11.cPsPcode,'') <> ''*/
--��ѯ���ϳ������ݽ���------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--��������Ŷ�Ӧ��������ʿ�ʼ
insert into #FlyTable011 select
rdrecord11.cDefine1 as �����,
CAST((1.00 - CAST(isnull(rdrecord11.cdefine9,'1') as decimal(20,6)))*100 as decimal(20,6)) as �����������,
CAST((1.00 - CAST(isnull(rdrecord11.cdefine2,'1') as decimal(20,6)))*100 as decimal(20,6)) as �����������
from rdrecords11
Left JOIN rdrecord11 ON rdrecords11.ID = rdrecord11.ID
where rdrecord11.cDefine1 in (select ����� from #FlyTable0) and isnull(rdrecord11.cPsPcode,'') <> ''
--��������Ŷ�Ӧ��������ʽ���
--�м���㿪ʼ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
insert into #FlyTable02 
SELECT LT0.����� as �����,LT00.��Ʒ���� as ��Ʒ����,LT00.��Ʒ���� as ��Ʒ����,LT00.��Ʒ��� as ��Ʒ���,LT1.����ԭ������ as ����ԭ������,LT00.��ϸ������� as ��ϸ�������,LT0.����������� as �����������,LT0.һ��ͨ������ as һ��ͨ������,
			(LT1.����ԭ������-LT0.�����������) as �������, CAST((cast(LT0.�����������/LT1.����ԭ������ as decimal(20,6))*100) as decimal(20,2)) as ������,
			isnull(CAST((1-CAST(((LT0.�����������/LT1.����ԭ������)) as decimal(20,6)))*100 as decimal(20,2)),0) as �����,
			isnull(LT2.�����������,0) as �����������,isnull(LT2.�����������,0) as �����������,
			'' as ���,0 as ����׼�������,CAST(((LT0.һ��ͨ������/LT1.����ԭ������)*100) as decimal(20,2)) as һ��ͨ����,
		cast(0 as decimal(20,6)) as ��׼����,
		0.00 as ��Ľ��
FROM (
select #FlyTable00.����� as �����,--#FlyTable00.��Ʒ���� as ��Ʒ����,#FlyTable00.��Ʒ���� as ��Ʒ����,#FlyTable00.��Ʒ��� as ��Ʒ���,
--sum(#FlyTable00.�����������)  as ��ϸ�������,
sum(#FlyTable00.�����������)  as �����������,
sum(#FlyTable00.һ��ͨ������)  as һ��ͨ������
from #FlyTable00 
group by #FlyTable00.�����--,#FlyTable00.��Ʒ���� ,#FlyTable00.��Ʒ����,#FlyTable00.��Ʒ���
) AS LT0
LEFT JOIN(
select #FlyTable00.����� as �����,#FlyTable00.��Ʒ���� as ��Ʒ����,#FlyTable00.��Ʒ���� as ��Ʒ����,#FlyTable00.��Ʒ��� as ��Ʒ���,
sum(#FlyTable00.�����������)  as ��ϸ�������--,
--sum(#FlyTable00.�����������)  as �����������,
--sum(#FlyTable00.һ��ͨ������)  as һ��ͨ������
from #FlyTable00 
group by #FlyTable00.�����,#FlyTable00.��Ʒ���� ,#FlyTable00.��Ʒ����,#FlyTable00.��Ʒ���
) AS LT00 ON LT0.����� = LT00.�����
--left join FR_CPNRW_PRICE_001 as x on LT00.��Ʒ���� = x.��Ʒ����
left join (
select #FlyTable01.����� as �����,
sum(#FlyTable01.����ԭ������) as ����ԭ������
from #FlyTable01 
group by #FlyTable01.�����) AS LT1 ON LT0.����� = LT1.�����
left join (
select #FlyTable011.����� as �����,
max(#FlyTable011.�����������) as �����������,
max(#FlyTable011.�����������) as �����������
from #FlyTable011
group by #FlyTable011.�����) AS LT2 ON LT0.����� = LT2.�����
--where LT1.����ԭ������ <> 0


--�м�������------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

select distinct
	y.�����,
y.��Ʒ����,y.��Ʒ����,y.��Ʒ���,
	y.����ԭ������,
	y.��ϸ�������,
	y.�����������,
	y.�������,
	y.������,
	y.�����,
  y.�����������,
	y.�����������,
	(case
		when (y.����� <= y.����������� AND y.����� >= y.�����������) then '����'
		when (y.����� < y.�����������) then '��Լ'
		when (y.����� > y.�����������) then '�˷�'
	end) as ���,
	(case
		when (y.����� <= y.����������� AND y.����� >= y.�����������) then 0
		when (y.����� < y.�����������) then (y.�������-(y.�����������*(y.�����������/100)))
		when (y.����� > y.�����������) then (y.�������-(y.�����������*(y.�����������/100)))
	end) as ����׼�������,
	y.һ��ͨ����,
	y.��׼����,
	(case
		when (y.����� <= y.����������� AND y.����� >= y.�����������) then 0.00
		when (y.����� < y.�����������) then ((y.�������-(y.�����������*(y.�����������/100)))*isnull(y.��׼����,0.00))
		when (y.����� > y.�����������) then ((y.�������-(y.�����������*(y.�����������/100)))*isnull(y.��׼����,0.00))
	end) as ��Ľ��
from #FlyTable02 y
--where ����ԭ������ is not NULL
drop table #FlyTable0
drop table #FlyTable00
drop table #FlyTable01
drop table #FlyTable011
drop table #FlyTable02

END





GO
SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO

