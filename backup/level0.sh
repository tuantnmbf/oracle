# Lấy PID của quy trình hiện tại
PID=$$

# Ghi PID vào tệp tin
echo $PID > /u01/backup/scriptbk/script_pid.pid

# Script for backup full
logfile=/u01/backup/log/$(date +%Y%m%d)_level0.log
export ORACLE_SID=cdb1
export NLS_DATE_FORMAT="yyyy-mm-dd hh24:mi:ss"
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=/u01/app/oracle/product/19.0.0/dbhome_1
export PATH=$ORACLE_HOME/bin:$PATH

# Thêm PID vào tên file log
#log_file="/u01/backup/log/$(date +%Y%m%d)_level0_${PID}.log"
log_file="/u01/backup/log/$(date +%Y%m%d)_level0.log"

# Ghi thông tin PID vào file log
echo "PID: $PID" >> $log_file

# Chạy lệnh RMAN và ghi log vào file
rman target / nocatalog log=$log_file cmdfile=/u01/backup/scriptbk/level0.rman

# Thoát khỏi script
exit
