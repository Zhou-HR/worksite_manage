#!/usr/bin/python
# -*- coding: utf-8 -*-
import psycopg2
import pdb
import datetime
import os
import xlsxwriter
import logging
import sys

reload(sys)
sys.setdefaultencoding('utf8')


# logging.basicConfig(filename='provinceFinedList_py.log', filemode="w", level=logging.INFO)

def color_me(color, msg):
    colors = {
        'red': '\033[31m',
        'green': '\033[32m',
        'reset': '\033[0m',
        'yellow': '\033[33m',
        'cyan': '\033[36m',
        'magenta': '\033[35m'
    }
    if color in colors:
        return colors[color] + str(msg) + colors['reset']
    else:
        return msg


def enotice(msg):
    timestamp = datetime.datetime.now().strftime('%F:%H:%M:%S')
    return color_me('yellow', msg + timestamp)


def einfo(msg):
    timestamp = datetime.datetime.now().strftime('%F:%H:%M:%S')
    return color_me('green', msg)


def ewarn(msg):
    timestamp = datetime.datetime.now().strftime('%F:%H:%M:%S')
    return color_me('red', msg)


def get_days():
    timestamp = datetime.datetime.now().strftime('%F')
    return timestamp


def get_hour():
    timestamp = datetime.datetime.now().strftime('%H')
    return timestamp


def get_previous_days():
    timestamp_day = datetime.datetime.now().strftime('%d')
    timestamp_day = int(timestamp_day)
    if int(timestamp_day) >= 0 and int(timestamp_day) <= 9:
        timestamp_day = '0' + str(timestamp_day)
    timestamp = datetime.datetime.now().strftime('%G-%m')
    timestamp = timestamp + '-' + str(timestamp_day)
    str(timestamp)
    # print timestamp
    return timestamp


def get_previous_hour():
    timestamp = datetime.datetime.utcnow().strftime('%H')
    timestamp = int(timestamp) + 6
    if int(timestamp) == 0:
        timestamp = 23
    if int(timestamp) > 0 and int(timestamp) <= 9:
        timestamp = '0' + str(timestamp)
    str(timestamp)
    return timestamp


def system_opera(sys_opera):
    os.system(sys_opera)


def sql():
    # pdb.set_trace()
    conn = psycopg2.connect(database=argv_database, user=argv_user, password=argv_password, host=argv_host,
                            port=argv_port)
    cur = conn.cursor()
    sql_msg = argv_sql
    cur.execute(sql_msg)
    result = cur.fetchall()
    i = 0
    workbook = xlsxwriter.Workbook(argv_file_path)
    worksheet = workbook.add_worksheet()
    title1Style = workbook.add_format()
    title2Style = workbook.add_format()
    contentStyle = workbook.add_format()
    xjStyle = workbook.add_format()
    title1YellowStyle = workbook.add_format()
    title1BlueStyle = workbook.add_format()
    title2BlueStyle = workbook.add_format()
    title2YellowStyle = workbook.add_format()
    xjYellowStyle = workbook.add_format()
    contentBlod = workbook.add_format()

    title1Style.set_font_size(12)
    title1Style.set_bold()
    title1Style.set_bg_color('#d9d9d9')
    title1Style.set_font_color('#010101')
    title1Style.set_align('center')
    title1Style.set_align('vcenter')
    title1Style.set_bottom(2)
    title1Style.set_top(2)
    title1Style.set_left(2)
    title1Style.set_right(2)

    title1YellowStyle.set_font_size(12)
    title1YellowStyle.set_bold()
    title1YellowStyle.set_bg_color('#ed7d31')
    title1YellowStyle.set_font_color('#010101')
    title1YellowStyle.set_align('center')
    title1YellowStyle.set_align('vcenter')
    title1YellowStyle.set_bottom(2)
    title1YellowStyle.set_top(2)
    title1YellowStyle.set_left(2)
    title1YellowStyle.set_right(2)

    title1BlueStyle.set_font_size(12)
    title1BlueStyle.set_bold()
    title1BlueStyle.set_bg_color('#5b9bd5')
    title1BlueStyle.set_font_color('#010101')
    title1BlueStyle.set_align('center')
    title1BlueStyle.set_align('vcenter')
    title1BlueStyle.set_bottom(2)
    title1BlueStyle.set_top(2)
    title1BlueStyle.set_left(2)
    title1BlueStyle.set_right(2)

    title2Style.set_font_size(10)
    title2Style.set_bold()
    title2Style.set_bg_color('#d9d9d9')
    title2Style.set_font_color('#010101')
    title2Style.set_align('center')
    title2Style.set_align('vcenter')
    title2Style.set_bottom(2)
    title2Style.set_top(2)
    title2Style.set_left(2)
    title2Style.set_right(2)

    title2BlueStyle.set_font_size(10)
    title2BlueStyle.set_bold()
    title2BlueStyle.set_bg_color('#5b9bd5')
    title2BlueStyle.set_font_color('#010101')
    title2BlueStyle.set_align('center')
    title2BlueStyle.set_align('vcenter')
    title2BlueStyle.set_bottom(2)
    title2BlueStyle.set_top(2)
    title2BlueStyle.set_left(2)
    title2BlueStyle.set_right(2)

    title2YellowStyle.set_font_size(10)
    title2YellowStyle.set_bold()
    title2YellowStyle.set_bg_color('#ed7d31')
    title2YellowStyle.set_font_color('#010101')
    title2YellowStyle.set_align('center')
    title2YellowStyle.set_align('vcenter')
    title2YellowStyle.set_bottom(2)
    title2YellowStyle.set_top(2)
    title2YellowStyle.set_left(2)
    title2YellowStyle.set_right(2)

    contentStyle.set_font_size(10)
    contentStyle.set_font_color('#010101')
    contentStyle.set_align('center')
    contentStyle.set_align('vcenter')
    contentStyle.set_bottom(2)
    contentStyle.set_top(2)
    contentStyle.set_left(2)
    contentStyle.set_right(2)

    contentBlod.set_font_size(10)
    contentBlod.set_bold()
    contentBlod.set_font_color('#010101')
    contentBlod.set_align('center')
    contentBlod.set_align('vcenter')
    contentBlod.set_bottom(2)
    contentBlod.set_top(2)
    contentBlod.set_left(2)
    contentBlod.set_right(2)

    xjStyle.set_font_size(10)
    xjStyle.set_bold()
    xjStyle.set_bg_color('#5b9bd5')
    xjStyle.set_font_color('#010101')
    xjStyle.set_align('center')
    xjStyle.set_align('vcenter')
    xjStyle.set_bottom(2)
    xjStyle.set_top(2)
    xjStyle.set_left(2)
    xjStyle.set_right(2)

    xjYellowStyle.set_font_size(10)
    xjYellowStyle.set_bold()
    xjYellowStyle.set_bg_color('#ed7d31')
    xjYellowStyle.set_font_color('#010101')
    xjYellowStyle.set_align('center')
    xjYellowStyle.set_align('vcenter')
    xjYellowStyle.set_bottom(2)
    xjYellowStyle.set_top(2)
    xjYellowStyle.set_left(2)
    xjYellowStyle.set_right(2)
    worksheet.merge_range(i, 0, 2, 0, "序号", title1Style)
    worksheet.merge_range(i, 1, 2, 1, "省公司", title1Style)
    worksheet.merge_range(i, 2, i, 11, '工程合同', title1BlueStyle)
    worksheet.merge_range(i, 12, i, 15, '采购合同', title1YellowStyle)

    i = 1

    worksheet.merge_range(i, 2, i, 5, '土建', title2BlueStyle)
    worksheet.merge_range(i, 6, i, 7, '接电', title2BlueStyle)
    worksheet.merge_range(i, 8, i, 10, '隐检资料', title2BlueStyle)
    worksheet.write(i + 1, 2, '钢筋', title2BlueStyle)
    worksheet.write(i + 1, 3, '混凝土', title2BlueStyle)
    worksheet.write(i + 1, 4, '地网', title2BlueStyle)
    worksheet.write(i + 1, 5, '其他', title2BlueStyle)
    worksheet.write(i + 1, 6, '材料', title2BlueStyle)
    worksheet.write(i + 1, 7, '工艺', title2BlueStyle)
    worksheet.write(i + 1, 8, '交底', title2BlueStyle)
    worksheet.write(i + 1, 9, '质保', title2BlueStyle)
    worksheet.write(i + 1, 10, '照片', title2BlueStyle)
    worksheet.merge_range(i, 11, i + 1, 11, '小计', xjStyle)

    worksheet.merge_range(i, 12, i, 13, '铁塔', title2YellowStyle)
    worksheet.write(i, 14, '配套', title2YellowStyle)
    worksheet.write(i + 1, 12, '产品', title2YellowStyle)
    worksheet.write(i + 1, 13, '安装', title2YellowStyle)
    worksheet.write(i + 1, 14, '配套', title2YellowStyle)
    worksheet.merge_range(i, 15, i + 1, 15, '小计', xjYellowStyle)

    i = 3
    xuhao = 1
    for content in result:
        worksheet.write(i, 0, xuhao, contentStyle)
        worksheet.write(i, 1, content[0], contentStyle)
        gc_xj = content[1] + content[3] + content[5] + content[7] + content[9] + content[11] + content[13] + content[
            15] + content[17]
        cg_xj = content[19] + content[21] + content[23]
        if content[2] > -1:
            worksheet.write(i, 2, content[1], contentStyle)
        if content[4] > -1:
            worksheet.write(i, 3, content[3], contentStyle)
        if content[6] > -1:
            worksheet.write(i, 4, content[5], contentStyle)
        if content[8] > -1:
            worksheet.write(i, 5, content[7], contentStyle)
        if content[10] > -1:
            worksheet.write(i, 6, content[9], contentStyle)
        if content[12] > -1:
            worksheet.write(i, 7, content[11], contentStyle)
        if content[14] > -1:
            worksheet.write(i, 8, content[13], contentStyle)
        if content[16] > -1:
            worksheet.write(i, 9, content[15], contentStyle)
        if content[18] > -1:
            worksheet.write(i, 10, content[17], contentStyle)
        if content[20] > -1:
            worksheet.write(i, 12, content[19], contentStyle)
        if content[22] > -1:
            worksheet.write(i, 13, content[21], contentStyle)
        if content[24] > -1:
            worksheet.write(i, 14, content[23], contentStyle)
        worksheet.write(i, 11, gc_xj, contentStyle)
        worksheet.write(i, 15, cg_xj, contentStyle)
        i = i + 1
        xuhao = xuhao + 1

    worksheet.merge_range(i, 0, i, 1, '合计', contentBlod)
    if i > 3:
        worksheet.write(i, 2, '=SUM(C4:C' + str(i) + ')', contentStyle)
        worksheet.write(i, 3, '=SUM(D4:D' + str(i) + ')', contentStyle)
        worksheet.write(i, 4, '=SUM(E4:E' + str(i) + ')', contentStyle)
        worksheet.write(i, 5, '=SUM(F4:F' + str(i) + ')', contentStyle)
        worksheet.write(i, 6, '=SUM(G4:G' + str(i) + ')', contentStyle)
        worksheet.write(i, 7, '=SUM(H4:H' + str(i) + ')', contentStyle)
        worksheet.write(i, 8, '=SUM(I4:I' + str(i) + ')', contentStyle)
        worksheet.write(i, 9, '=SUM(J4:J' + str(i) + ')', contentStyle)
        worksheet.write(i, 10, '=SUM(K4:K' + str(i) + ')', contentStyle)
        worksheet.write(i, 11, '=SUM(L4:L' + str(i) + ')', contentStyle)
        worksheet.write(i, 12, '=SUM(M4:M' + str(i) + ')', contentStyle)
        worksheet.write(i, 13, '=SUM(N4:N' + str(i) + ')', contentStyle)
        worksheet.write(i, 14, '=SUM(O4:O' + str(i) + ')', contentStyle)
        worksheet.write(i, 15, '=SUM(P4:P' + str(i) + ')', contentStyle)
        i = i + 1
    worksheet.merge_range(i, 0, i, 15, "时间段" + argv_peroid, contentStyle)

    cur.close()
    conn.close()
    workbook.close()


argv_database = sys.argv[1]
argv_user = sys.argv[2]
argv_password = sys.argv[3]
argv_host = sys.argv[4]
argv_port = sys.argv[5]
argv_sql = sys.argv[6]
argv_file_path = sys.argv[7]
argv_peroid = sys.argv[8]
# logging.info(argv_sql)
sql()
