#!/usr/bin/python
# -*- coding: utf-8 -*-
import psycopg2
import pdb
import datetime
import os
import xlsxwriter
import sys

reload(sys)
sys.setdefaultencoding('utf8')


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

    worksheet.merge_range(i, 0, i, 9, u"基础信息", title1Style)
    worksheet.merge_range(i, 10, i, 19, '工程合同', title1BlueStyle)
    worksheet.merge_range(i, 20, i, 23, '采购合同', title1YellowStyle)

    i = 1
    worksheet.merge_range(i, 0, i + 1, 0, '序号', title2Style)
    worksheet.merge_range(i, 1, i + 1, 1, '编号', title2Style)
    worksheet.merge_range(i, 2, i + 1, 2, '省公司', title2Style)
    worksheet.merge_range(i, 3, i + 1, 3, '事业部', title2Style)
    worksheet.merge_range(i, 4, i + 1, 4, '名称', title2Style)
    worksheet.merge_range(i, 5, i + 1, 5, '站型', title2Style)
    worksheet.merge_range(i, 6, i + 1, 6, '基础', title2Style)
    worksheet.merge_range(i, 7, i + 1, 7, ' 塔型', title2Style)
    worksheet.merge_range(i, 8, i + 1, 8, '土建单位', title2Style)
    worksheet.merge_range(i, 9, i + 1, 9, '接电单位', title2Style)

    worksheet.merge_range(i, 10, i, 13, '土建', title2BlueStyle)
    worksheet.merge_range(i, 14, i, 15, '接电', title2BlueStyle)
    worksheet.merge_range(i, 16, i, 18, '隐检资料', title2BlueStyle)
    worksheet.write(i + 1, 10, '钢筋', title2BlueStyle)
    worksheet.write(i + 1, 11, '混凝土', title2BlueStyle)
    worksheet.write(i + 1, 12, '地网', title2BlueStyle)
    worksheet.write(i + 1, 13, '其他', title2BlueStyle)
    worksheet.write(i + 1, 14, '材料', title2BlueStyle)
    worksheet.write(i + 1, 15, '工艺', title2BlueStyle)
    worksheet.write(i + 1, 16, '交底', title2BlueStyle)
    worksheet.write(i + 1, 17, '质保', title2BlueStyle)
    worksheet.write(i + 1, 18, '照片', title2BlueStyle)
    worksheet.merge_range(i, 19, i + 1, 19, '小计', xjStyle)

    worksheet.merge_range(i, 20, i, 21, '铁塔', title2YellowStyle)
    worksheet.write(i, 22, '配套', title2YellowStyle)
    worksheet.write(i + 1, 20, '产品', title2YellowStyle)
    worksheet.write(i + 1, 21, '安装', title2YellowStyle)
    worksheet.write(i + 1, 22, '配套', title2YellowStyle)
    worksheet.merge_range(i, 23, i + 1, 23, '小计', xjYellowStyle)

    i = 3
    xuhao = 1
    for content in result:
        print
        content
        worksheet.write(i, 0, xuhao, contentStyle)
        worksheet.write(i, 1, content[0], contentStyle)
        worksheet.write(i, 2, content[1], contentStyle)
        worksheet.write(i, 3, content[2], contentStyle)
        worksheet.write(i, 4, content[3], contentStyle)
        worksheet.write(i, 5, content[4], contentStyle)
        worksheet.write(i, 6, content[5], contentStyle)
        worksheet.write(i, 7, content[6], contentStyle)
        worksheet.write(i, 8, content[7], contentStyle)
        worksheet.write(i, 9, content[8], contentStyle)
        gc_xj = content[9] + content[11] + content[13] + content[15] + content[17] + content[19] + content[21] + \
                content[23] + content[25]
        cg_xj = content[27] + content[29] + content[31]
        if content[10] > -1:
            worksheet.write(i, 10, content[9], contentStyle)
        if content[12] > -1:
            worksheet.write(i, 11, content[11], contentStyle)
        if content[14] > -1:
            worksheet.write(i, 12, content[13], contentStyle)
        if content[16] > -1:
            worksheet.write(i, 13, content[15], contentStyle)
        if content[18] > -1:
            worksheet.write(i, 14, content[17], contentStyle)
        if content[20] > -1:
            worksheet.write(i, 15, content[19], contentStyle)
        if content[22] > -1:
            worksheet.write(i, 16, content[21], contentStyle)
        if content[24] > -1:
            worksheet.write(i, 17, content[23], contentStyle)
        if content[26] > -1:
            worksheet.write(i, 18, content[25], contentStyle)
        if content[28] > -1:
            worksheet.write(i, 20, content[27], contentStyle)
        if content[30] > -1:
            worksheet.write(i, 21, content[29], contentStyle)
        if content[32] > -1:
            worksheet.write(i, 22, content[31], contentStyle)
        worksheet.write(i, 19, gc_xj, contentStyle)
        worksheet.write(i, 23, cg_xj, contentStyle)
        i = i + 1
        xuhao = xuhao + 1

    worksheet.merge_range(i, 0, i, 9, '合计', contentBlod)
    if i > 3:
        worksheet.write(i, 10, '=SUM(K4:K' + str(i) + ')', contentStyle)
        worksheet.write(i, 11, '=SUM(L4:L' + str(i) + ')', contentStyle)
        worksheet.write(i, 12, '=SUM(M4:M' + str(i) + ')', contentStyle)
        worksheet.write(i, 13, '=SUM(N4:N' + str(i) + ')', contentStyle)
        worksheet.write(i, 14, '=SUM(O4:O' + str(i) + ')', contentStyle)
        worksheet.write(i, 15, '=SUM(P4:P' + str(i) + ')', contentStyle)
        worksheet.write(i, 16, '=SUM(Q4:Q' + str(i) + ')', contentStyle)
        worksheet.write(i, 17, '=SUM(R4:R' + str(i) + ')', contentStyle)
        worksheet.write(i, 18, '=SUM(S4:S' + str(i) + ')', contentStyle)
        worksheet.write(i, 19, '=SUM(T4:T' + str(i) + ')', contentStyle)
        worksheet.write(i, 20, '=SUM(U4:U' + str(i) + ')', contentStyle)
        worksheet.write(i, 21, '=SUM(V4:V' + str(i) + ')', contentStyle)
        worksheet.write(i, 22, '=SUM(W4:W' + str(i) + ')', contentStyle)
        worksheet.write(i, 23, '=SUM(X4:X' + str(i) + ')', contentStyle)
        i = i + 1
    worksheet.merge_range(i, 0, i, 23, "时间段:" + argv_peroid, contentStyle)

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
sql()
