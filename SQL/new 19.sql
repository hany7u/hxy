CREATE OR REPLACE VIEW V_GLFYTAB AS
/*折旧费*/
SELECT DISTINCT glvou.num,gl.yearv, gl.periodv,substr(glvou.prepareddate,1,10) preparedate,substr(glvou.prepareddate,1,4) iYEAR,substr(glvou.prepareddate,6,2) imonth,
substr(glvou.prepareddate,9,2) days,smuser.cuserid,smuser.user_name,glvou.billmaker,glvou.pk_system,glvou.discardflag,gl.assid,accsubj.code subjcode,
accsubj.name subjname,gl.creditamount,gl.debitamount,gl_docfree1.f1,org_dept_v.code deptcode,org_dept_v.name deptname,org_dept_v.pk_org,
org.code orgcode,org.name orgname,org_dept_v.pk_group,grp.code grpcode,grp.name grpname,'' cuscode,'' cusname
FROM gl_docfree1 INNER JOIN org_dept_v  ON gl_docfree1.f1=org_dept_v.pk_dept
INNER JOIN org_orgs_v org ON org.pk_org=org_dept_v.pk_org
INNER JOIN org_group grp ON grp.pk_group=gl_docfree1.pk_group AND grp.pk_group=org_dept_v.pk_group
Inner JOIN gl_detail gl ON gl.assid=gl_docfree1.assid
RIGHT JOIN bd_account accsubj ON accsubj.pk_account=gl.pk_account
INNER JOIN gl_voucher glvou ON glvou.pk_voucher=gl.pk_voucher
inner join sm_user smuser on smuser.cuserid=glvou.billmaker
WHERE gl_docfree1.f1<>'NN/A' AND gl_docfree1.f1<>'~'
 AND nvl(org_dept_v.dr,0)=0 AND nvl(gl_docfree1.dr,0)=0
 AND nvl(org.dr,0)=0 AND nvl(grp.dr,0)=0
 AND nvl(gl.dr,0)=0 AND nvl(accsubj.dr,0)=0
 AND glvou.pk_system IN ('GL','FA','IA')
 AND glvou.discardflag='N'
 AND gl.yearv>=2015 AND gl.periodv>'00'
 AND accsubj.code IN ('510110','510115',
'53010110','53010115','660110',
'660210','660215','660216', '660218')----折旧费去掉了生产成本下面的，将固定资产模块的凭证加入。2015-04-02 zsy

UNION ALL
/*工资**/
SELECT DISTINCT glvou.num,gl.yearv, gl.periodv,substr(glvou.prepareddate,1,10) preparedate,substr(glvou.prepareddate,1,4) iYEAR,substr(glvou.prepareddate,6,2) imonth,
substr(glvou.prepareddate,9,2) days,smuser.cuserid,smuser.user_name,glvou.billmaker,glvou.pk_system,glvou.discardflag,gl.assid,accsubj.code subjcode,
'工资' subjname,gl.creditamount,gl.debitamount,gl_docfree1.f1,org_dept_v.code deptcode,org_dept_v.name deptname,org_dept_v.pk_org,
org.code orgcode,org.name orgname,org_dept_v.pk_group,grp.code grpcode,grp.name grpname,'' cuscode,'' cusname
FROM gl_docfree1 INNER JOIN org_dept_v  ON gl_docfree1.f1=org_dept_v.pk_dept
INNER JOIN org_orgs_v org ON org.pk_org=org_dept_v.pk_org
INNER JOIN org_group grp ON grp.pk_group=gl_docfree1.pk_group AND grp.pk_group=org_dept_v.pk_group
Inner JOIN gl_detail gl ON gl.assid=gl_docfree1.assid
RIGHT JOIN bd_account accsubj ON accsubj.pk_account=gl.pk_account
INNER JOIN gl_voucher glvou ON glvou.pk_voucher=gl.pk_voucher
inner join sm_user smuser on smuser.cuserid=glvou.billmaker
WHERE gl_docfree1.f1<>'NN/A' AND gl_docfree1.f1<>'~'
 AND nvl(org_dept_v.dr,0)=0 AND nvl(gl_docfree1.dr,0)=0
 AND nvl(org.dr,0)=0 AND nvl(grp.dr,0)=0
 AND nvl(gl.dr,0)=0 AND nvl(accsubj.dr,0)=0
 AND glvou.pk_system IN ('GL','FA','IA')
 AND glvou.discardflag='N'
 AND gl.yearv>=2015 AND gl.periodv>'00'
 AND accsubj.code  = '221101'----折旧费去掉了生产成本下面的，将固定资产模块的凭证加入。2015-04-02 zsy

UNION ALL
/*机物料消耗*/
SELECT DISTINCT glvou.num,gl.yearv, gl.periodv,substr(glvou.prepareddate,1,10) preparedate,substr(glvou.prepareddate,1,4) iYEAR,substr(glvou.prepareddate,6,2) imonth,
substr(glvou.prepareddate,9,2) days,smuser.cuserid,smuser.user_name,glvou.billmaker,glvou.pk_system,glvou.discardflag,gl.assid,'510107' subjcode,
'机物料消耗' subjname,gl.creditamount,gl.debitamount,gl_docfree1.f1,org_dept_v.code deptcode,org_dept_v.name deptname,org_dept_v.pk_org,
org.code orgcode,org.name orgname,org_dept_v.pk_group,grp.code grpcode,grp.name grpname,'' cuscode,'' cusname
FROM gl_docfree1 INNER JOIN org_dept_v  ON gl_docfree1.f1=org_dept_v.pk_dept
INNER JOIN org_orgs_v org ON org.pk_org=org_dept_v.pk_org
INNER JOIN org_group grp ON grp.pk_group=gl_docfree1.pk_group AND grp.pk_group=org_dept_v.pk_group
Inner JOIN gl_detail gl ON gl.assid=gl_docfree1.assid
RIGHT JOIN bd_account accsubj ON accsubj.pk_account=gl.pk_account
INNER JOIN gl_voucher glvou ON glvou.pk_voucher=gl.pk_voucher
inner join sm_user smuser on smuser.cuserid=glvou.billmaker
WHERE gl_docfree1.f1<>'NN/A' AND gl_docfree1.f1<>'~'
 AND nvl(org_dept_v.dr,0)=0 AND nvl(gl_docfree1.dr,0)=0
 AND nvl(org.dr,0)=0 AND nvl(grp.dr,0)=0
 AND nvl(gl.dr,0)=0 AND nvl(accsubj.dr,0)=0
 AND glvou.pk_system IN ('GL','IA')
 AND glvou.discardflag='N'
 AND gl.yearv>=2015 AND gl.periodv>'00'
 AND accsubj.code= '500104'

 UNION ALL
/*办公费、包材、机物料消耗、公司产品、样品费用、玉米存储费、客户赔偿等*/
 SELECT DISTINCT glvou.num,gl.yearv, gl.periodv,substr(glvou.prepareddate,1,10) preparedate,substr(glvou.prepareddate,1,4) iYEAR,substr(glvou.prepareddate,6,2) imonth,
 substr(glvou.prepareddate,9,2) days,smuser.cuserid,smuser.user_name,glvou.billmaker,glvou.pk_system,glvou.discardflag,gl.assid,accsubj.code subjcode,
accsubj.name subjname,gl.creditamount,gl.debitamount,gl_docfree1.f1,org_dept_v.code deptcode,org_dept_v.name deptname,org_dept_v.pk_org,
org.code orgcode,org.name orgname,org_dept_v.pk_group,grp.code grpcode,grp.name grpname,'' cuscode,'' cusname
FROM gl_docfree1 INNER JOIN org_dept_v  ON gl_docfree1.f1=org_dept_v.pk_dept
INNER JOIN org_orgs_v org ON org.pk_org=org_dept_v.pk_org
INNER JOIN org_group grp ON grp.pk_group=gl_docfree1.pk_group AND grp.pk_group=org_dept_v.pk_group
Inner JOIN gl_detail gl ON gl.assid=gl_docfree1.assid
Right JOIN bd_account accsubj ON accsubj.pk_account=gl.pk_account
INNER JOIN gl_voucher glvou ON glvou.pk_voucher=gl.pk_voucher
inner join sm_user smuser on smuser.cuserid=glvou.billmaker
WHERE gl_docfree1.f1<>'NN/A' AND gl_docfree1.f1<>'~'
 AND nvl(org_dept_v.dr,0)=0 AND nvl(gl_docfree1.dr,0)=0
 AND nvl(org.dr,0)=0 AND nvl(grp.dr,0)=0
 AND nvl(gl.dr,0)=0 AND nvl(accsubj.dr,0)=0
 AND glvou.pk_system IN ('GL','IA')
 AND glvou.discardflag='N'
AND smuser.user_name IN('温文秀','李德镇','武洪峰','修风燕')---添加武洪峰做的单子，2016-12-08；增加修凤燕做的单子，2018-04-12
 AND gl.yearv>=2015 AND gl.periodv>'00'
 AND accsubj.code IN ('510104','660104', '660204','660119','53010101','660120',
 '500108','510116','510117', '510118','53010104','5301010903','66010903','660118',
 '660119','660120','660123','660204','66020903','660224')-----,'660113',将510125、660223保洁费两个科目去掉，只取报销单数据2015-04-02
 UNION ALL
 /*社会保险费、住房公积金*/
  SELECT DISTINCT glvou.num,gl.yearv, gl.periodv,substr(glvou.prepareddate,1,10) preparedate,substr(glvou.prepareddate,1,4) iYEAR,substr(glvou.prepareddate,6,2) imonth,
 substr(glvou.prepareddate,9,2) days,smuser.cuserid,smuser.user_name,glvou.billmaker,glvou.pk_system,glvou.discardflag,gl.assid,accsubj.code subjcode,
accsubj.name subjname,(gl.creditamount) creditamount,(gl.debitamount) debitamount,gl_docfree1.f1,org_dept_v.code deptcode,org_dept_v.name deptname,org_dept_v.pk_org,
org.code orgcode,org.name orgname,org_dept_v.pk_group,grp.code grpcode,grp.name grpname,'' cuscode,'' cusname
FROM gl_docfree1 INNER JOIN org_dept_v  ON gl_docfree1.f1=org_dept_v.pk_dept
INNER JOIN org_orgs_v org ON org.pk_org=org_dept_v.pk_org
INNER JOIN org_group grp ON grp.pk_group=gl_docfree1.pk_group AND grp.pk_group=org_dept_v.pk_group
Inner JOIN gl_detail gl ON gl.assid=gl_docfree1.assid
RIGHT JOIN bd_account accsubj ON accsubj.pk_account=gl.pk_account
INNER JOIN gl_voucher glvou ON glvou.pk_voucher=gl.pk_voucher
inner join sm_user smuser on smuser.cuserid=glvou.billmaker
WHERE gl_docfree1.f1<>'NN/A' AND gl_docfree1.f1<>'~'
 AND nvl(org_dept_v.dr,0)=0 AND nvl(gl_docfree1.dr,0)=0
 AND nvl(org.dr,0)=0 AND nvl(grp.dr,0)=0
 AND nvl(gl.dr,0)=0 AND nvl(accsubj.dr,0)=0
 AND glvou.pk_system IN ('GL','IA')
 AND glvou.discardflag='N'

 AND gl.yearv>=2015 AND gl.periodv>'00'
 AND accsubj.code IN ('66020203','66020206','66010203','66010206'
 ,'51010203','51010206','530101010203','530101010206')

  UNION ALL
/*修理费、劳动保护费*/
 SELECT DISTINCT glvou.num,gl.yearv, gl.periodv,substr(glvou.prepareddate,1,10) preparedate,substr(glvou.prepareddate,1,4) iYEAR,substr(glvou.prepareddate,6,2) imonth,
 substr(glvou.prepareddate,9,2) days,smuser.cuserid,smuser.user_name,glvou.billmaker,glvou.pk_system,glvou.discardflag,gl.assid,accsubj.code subjcode,
accsubj.name subjname,gl.creditamount,gl.debitamount,gl_docfree1.f1,org_dept_v.code deptcode,org_dept_v.name deptname,org_dept_v.pk_org,
org.code orgcode,org.name orgname,org_dept_v.pk_group,grp.code grpcode,grp.name grpname,'' cuscode,'' cusname
FROM gl_docfree1 INNER JOIN org_dept_v  ON gl_docfree1.f1=org_dept_v.pk_dept
INNER JOIN org_orgs_v org ON org.pk_org=org_dept_v.pk_org
INNER JOIN org_group grp ON grp.pk_group=gl_docfree1.pk_group AND grp.pk_group=org_dept_v.pk_group
Inner JOIN gl_detail gl ON gl.assid=gl_docfree1.assid
Right JOIN bd_account accsubj ON accsubj.pk_account=gl.pk_account
INNER JOIN gl_voucher glvou ON glvou.pk_voucher=gl.pk_voucher
inner join sm_user smuser on smuser.cuserid=glvou.billmaker
WHERE gl_docfree1.f1<>'NN/A' AND gl_docfree1.f1<>'~'
 AND nvl(org_dept_v.dr,0)=0 AND nvl(gl_docfree1.dr,0)=0
 AND nvl(org.dr,0)=0 AND nvl(grp.dr,0)=0
 AND nvl(gl.dr,0)=0 AND nvl(accsubj.dr,0)=0
 AND glvou.pk_system IN ('GL','IA')
 AND glvou.discardflag='N'
AND smuser.user_name IN('李德镇','武洪峰','修风燕','张元忠')--增加修凤燕做的单子，2018-04-12增加张元忠2018-10-29
 AND gl.yearv>=2015 AND gl.periodv>'00'
 AND accsubj.code IN ('510103','510111','660111','660211')----'510126','660217',
UNION ALL
/*电费、气费*/
  SELECT DISTINCT glvou.num,gl.yearv, gl.periodv,substr(glvou.prepareddate,1,10) preparedate,substr(glvou.prepareddate,1,4) iYEAR,substr(glvou.prepareddate,6,2) imonth,
 substr(glvou.prepareddate,9,2) days,smuser.cuserid,smuser.user_name,glvou.billmaker,glvou.pk_system,glvou.discardflag,gl.assid,accsubj.code subjcode,
accsubj.name subjname,(gl.creditamount) creditamount,(gl.debitamount) debitamount,gl_docfree1.f1,org_dept_v.code deptcode,org_dept_v.name deptname,org_dept_v.pk_org,
org.code orgcode,org.name orgname,org_dept_v.pk_group,grp.code grpcode,grp.name grpname,'' cuscode,'' cusname
FROM gl_docfree1 INNER JOIN org_dept_v  ON gl_docfree1.f1=org_dept_v.pk_dept
INNER JOIN org_orgs_v org ON org.pk_org=org_dept_v.pk_org
INNER JOIN org_group grp ON grp.pk_group=gl_docfree1.pk_group AND grp.pk_group=org_dept_v.pk_group
Inner JOIN gl_detail gl ON gl.assid=gl_docfree1.assid
RIGHT JOIN bd_account accsubj ON accsubj.pk_account=gl.pk_account
INNER JOIN gl_voucher glvou ON glvou.pk_voucher=gl.pk_voucher
inner join sm_user smuser on smuser.cuserid=glvou.billmaker
WHERE gl_docfree1.f1<>'NN/A' AND gl_docfree1.f1<>'~'
 AND nvl(org_dept_v.dr,0)=0 AND nvl(gl_docfree1.dr,0)=0
 AND nvl(org.dr,0)=0 AND nvl(grp.dr,0)=0
 AND nvl(gl.dr,0)=0 AND nvl(accsubj.dr,0)=0
 --AND glvou.pk_system IN ('GL','IA')
 AND glvou.discardflag='N'

 AND gl.yearv>=2015 AND gl.periodv>'00'---2015-07-30加入工会经费、汽费(王龙月要求加上）10-8jiaru 电费(2016-05-11去掉工会经费改为取费用报销单数据）
 AND accsubj.code IN ('500107','510114','53010114','660214','500106','510113','53010113','660213')

 /*('51010204','5301010204'
 ,'66010204','66020204','500107','510114','53010114','660214','500106','510113','53010113','660213')*/
 UNION ALL
 /*礼品招待、周转箱或周转桶租赁费*/
 SELECT DISTINCT glvou.num,gl.yearv, gl.periodv,substr(glvou.prepareddate,1,10) preparedate,substr(glvou.prepareddate,1,4) iYEAR,substr(glvou.prepareddate,6,2) imonth,
 substr(glvou.prepareddate,9,2) days,smuser.cuserid,smuser.user_name,glvou.billmaker,glvou.pk_system,glvou.discardflag,gl.assid,accsubj.code subjcode,
case when accsubj.name='礼品招待费' then '招待费-礼品招待费' else accsubj.name end subjname,gl.creditamount,gl.debitamount,gl_docfree1.f1,org_dept_v.code deptcode,org_dept_v.name deptname,org_dept_v.pk_org,
org.code orgcode,org.name orgname,org_dept_v.pk_group,grp.code grpcode,grp.name grpname,'' cuscode,'' cusname
FROM gl_docfree1 INNER JOIN org_dept_v  ON gl_docfree1.f1=org_dept_v.pk_dept
INNER JOIN org_orgs_v org ON org.pk_org=org_dept_v.pk_org
INNER JOIN org_group grp ON grp.pk_group=gl_docfree1.pk_group AND grp.pk_group=org_dept_v.pk_group
Inner JOIN gl_detail gl ON gl.assid=gl_docfree1.assid
Right JOIN bd_account accsubj ON accsubj.pk_account=gl.pk_account
INNER JOIN gl_voucher glvou ON glvou.pk_voucher=gl.pk_voucher
inner join sm_user smuser on smuser.cuserid=glvou.billmaker
WHERE gl_docfree1.f1<>'NN/A' AND gl_docfree1.f1<>'~'
 AND nvl(org_dept_v.dr,0)=0 AND nvl(gl_docfree1.dr,0)=0
 AND nvl(org.dr,0)=0 AND nvl(grp.dr,0)=0
 AND nvl(gl.dr,0)=0 AND nvl(accsubj.dr,0)=0
 AND glvou.pk_system ='IA'
 AND glvou.discardflag='N'
AND smuser.user_name IN ('李德镇','武洪峰','修风燕')--增加修凤燕做的单子，2018-04-12
 AND gl.yearv>=2015 AND gl.periodv>'00'
 AND accsubj.code IN ('66020902','66010902','51010902','5301010902','660116')
;
