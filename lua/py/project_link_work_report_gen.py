#!/usr/bin/python
# -*- coding: utf-8 -*-
import psycopg2
import pdb
import datetime
import os
import logging
import xlsxwriter
import sys
import time
import datetime

reload(sys)
sys.setdefaultencoding('utf8')


# logging.basicConfig(filename='projOptionList_py.log', filemode="w", level=logging.INFO)

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
    conn = psycopg2.connect(database=argv_database, user=argv_user, password=argv_password, host=argv_host,
                            port=argv_port)
    cur = conn.cursor()
    sql_msg = argv_sql
    cur.execute(sql_msg)
    result = cur.fetchall()
    logging.info(result)

    i = 0
    # 创建execl
    workbook = xlsxwriter.Workbook(argv_file_path)
    # sheet页
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
    # 设置样式
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

    title2BlueStyle.set_font_size(15)
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

    # 设置字段
    worksheet.write(i, 0, "序号", title2BlueStyle)
    worksheet.write(i, 1, "省公司", title2BlueStyle)
    worksheet.write(i, 2, "事业部", title2BlueStyle)
    worksheet.write(i, 3, "项目编号", title2BlueStyle)
    worksheet.write(i, 4, "基站名称", title2BlueStyle)
    worksheet.write(i, 5, "站型", title2BlueStyle)
    worksheet.write(i, 6, "塔型", title2BlueStyle)
    worksheet.write(i, 7, "一级工序", title2BlueStyle)
    worksheet.write(i, 8, "二级工序", title2BlueStyle)
    worksheet.write(i, 9, "提报时间", title2BlueStyle)
    worksheet.write(i, 10, "审核状态", title2BlueStyle)
    worksheet.write(i, 11, "审核时间", title2BlueStyle)
    worksheet.write(i, 12, "审核人", title2BlueStyle)
    worksheet.write(i, 13, "扣款金额", title2BlueStyle)
    worksheet.write(i, 14, "扣款时间", title2BlueStyle)
    worksheet.write(i, 15, "扣款人", title2BlueStyle)

    i = 1
    xuhao = 1
    # 遍历值
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
        if (content[8] is not None) and content[8] > 0:
            timeArray = time.localtime(content[8])
            otherStyleTime1 = time.strftime("%Y--%m--%d %H:%M:%S", timeArray)
            worksheet.write(i, 9, otherStyleTime1, contentStyle)
        else:
            worksheet.write(i, 9, None, contentStyle)
        if content[9] == 0:
            worksheet.write(i, 10, "未提交", contentStyle)
        if content[9] == 1:
            worksheet.write(i, 10, "已提交未审核", contentStyle)
        if content[9] == 2:
            worksheet.write(i, 10, "审核不通过", contentStyle)
        if content[9] == 3:
            worksheet.write(i, 10, "审核通过", contentStyle)
        if content[9] == 4:
            worksheet.write(i, 10, "审核不通过并且留档", contentStyle)
        if content[9] == 5:
            worksheet.write(i, 10, "审核条件通过", contentStyle)
        if content[9] == 6:
            worksheet.write(i, 10, "该施工环节被禁用", contentStyle)
        if content[9] == 7:
            worksheet.write(i, 10, "该环节审核通过尚需审核员在web端进行扣款", contentStyle)
        if content[9] == 8:
            worksheet.write(i, 10, "该环节审核条件通过尚需审核员在web端进行扣款", contentStyle)
        if (content[10] is not None) and content[10] > 0:
            timeArray = time.localtime(content[10])
            otherStyleTime = time.strftime("%Y--%m--%d %H:%M:%S", timeArray)
            worksheet.write(i, 11, otherStyleTime, contentStyle)
        else:
            worksheet.write(i, 11, None, contentStyle)
        worksheet.write(i, 12, content[11], contentStyle)
        worksheet.write(i, 13, content[12], contentStyle)
        if (content[13] is not None) and content[13] > 0:
            timeArray2 = time.localtime(content[13])
            otherStyleTime2 = time.strftime("%Y--%m--%d %H:%M:%S", timeArray2)
            worksheet.write(i, 14, otherStyleTime2, contentStyle)
        else:
            worksheet.write(i, 14, None, contentStyle)
        worksheet.write(i, 15, content[14], contentStyle)
        i = i + 1
        xuhao = xuhao + 1

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
