-- Giả sử ta có một DB với tham số như sau, đây cũng chính là tham số DB test của tôi:

oracle@db2 10.0.2.15:scriptbk$ env | grep -i oracl
ORACLE_UNQNAME=cdb1
DB_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
USER=oracle
LD_LIBRARY_PATH=/u01/app/oracle/product/19.0.0/dbhome_1/lib:/lib:/usr/lib
ORACLE_SID=cdb1
ORACLE_BASE=/u01/app/oracle
ORACLE_HOSTNAME=db2.localdomain
MAIL=/var/spool/mail/oracle
PATH=/u01/app/oracle/product/19.0.0/dbhome_1/bin:/usr/sbin:/usr/local/bin:/u01/app/oracle/product/19.0.0/dbhome_1/bin:/usr/sbin:/usr/local/bin:/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/oracle/.local/bin:/home/oracle/bin:/home/oracle/.local/bin:/home/oracle/bin
HOME=/home/oracle
LOGNAME=oracle
CLASSPATH=/u01/app/oracle/product/19.0.0/dbhome_1/jlib:/u01/app/oracle/product/19.0.0/dbhome_1/rdbms/jlib
ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
-- Vậy để bắt đầu viết thủ tục, tôi sẽ qui hoạch folder dùng cho việc chứa script và backup file:

oracle@db2 10.0.2.15:backup$ pwd
/u01/backup
oracle@db2 10.0.2.15:backup$ tree -L 2
.
├── level0
│   ├── arc_20240422_CDB1_092otvf8_9_092otvf8_1_1
│   ├── control_file_c-1136356795-20240422-04
│   ├── data_file_20240422_CDB1_062otv1i_6
│   └── data_file_20240422_CDB1_072otve9_7
├── level1
│   ├── arc_20240422_CDB1_0f2ou2rd_15_0f2ou2rd_1_1
│   ├── control_file_c-1136356795-20240422-05
│   ├── control_file_c-1136356795-20240422-06
│   └── data_file_20240422_CDB1_0c2ou2mn_12
├── log
│   ├── 20240422_level0_9342.log
│   └── 20240422_level1_12904.log
└── scriptbk
    ├── level0.rman
    ├── level0.sh
    ├── level1.rman
    └── level1.sh

4 directories, 14 files
-- Trong đó:

Thư mục "scriptbk" chứa các script tập hợp các câu lệnh chạy backup. 
Thư mục "log" chứa log tập trung cho quá trình backup.
Thư mục "level0" và "level1" chứa các backup file, là kết quả cuối cùng của quá trình backup.
