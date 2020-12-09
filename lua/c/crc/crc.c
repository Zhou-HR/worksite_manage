#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

/*
            1、预置16位寄存器为十六进制FFFF（即全为1）。称此寄存器为CRC寄存器； 
            2、把第一个8位数据与16位CRC寄存器的低位相异或，把结果放于CRC寄存器； 
            3、把寄存器的内容右移一位(朝低位)，用0填补最高位，检查最低位； 
            4、如果最低位为0：重复第3步(再次移位); 如果最低位为1：CRC寄存器与多项式A001（1010 0000 0000 0001）进行异或； 
            5、重复步骤3和4，直到右移8次，这样整个8位数据全部进行了处理； 
            6、重复步骤2到步骤5，进行下一个8位数据的处理； 
            7、最后得到的CRC寄存器即为CRC码。
            */
static int getCRC16(lua_State* L){
	uint16_t CRCNumber = 0;
	char tempHex[3];
	char *endptr;
	long lnumber;
	uint16_t lnumber16 ;
	int i ,j,sLen;
	uint16_t CRCREG = (uint16_t)0xffff;
	
	uint16_t H_crc ;
  uint16_t L_crc ;
  uint16_t ret;
  
	
	const char* s = luaL_checkstring(L,1);
	sLen = strlen(s);
	
	tempHex[0] = 0;
	tempHex[1] = 0;
	tempHex[2] = 0;
	
	for( i = 0; i < sLen; ){
		tempHex[0] = *(s+i);
		tempHex[1] = *(s+i+1);
		
		lnumber = strtol(tempHex, &endptr, 16);
		lnumber16 = (uint16_t)lnumber;
		
		CRCREG = (uint16_t)(CRCREG ^ (uint16_t)lnumber16);//<< 8;
    for ( j = 0; j < 8; j++)
    {
        uint16_t CRCtmp = (uint16_t)(CRCREG & (uint16_t)0x0001);
        CRCREG = (uint16_t)(CRCREG >> (uint16_t)1);
        if (CRCtmp == (uint16_t)1)
        {
            CRCREG = (uint16_t)(CRCREG ^ (uint16_t)0xA001);
        }
    }
		i += 2;
	}
	H_crc = (uint16_t)((CRCREG >> 8) & 0xFF);
  L_crc = (uint16_t)(CRCREG & 0xFF);
  //ret = (uint16_t)(((uint16_t)L_char << 8) | (uint16_t)H_char);
  ret = (uint16_t)(L_crc*256 + H_crc);
  
  CRCNumber =  ret;
   
	lua_pushnumber(L,CRCNumber);
	lua_pushnumber(L,L_crc);
	lua_pushnumber(L,H_crc);
  return 3;
}

static int b_and(lua_State* L){
	const uint32_t number1 = luaL_checknumber(L,1);
	const uint32_t number2 = luaL_checknumber(L,2);
	
	if((number1 & number2) > 0){
		lua_pushnumber(L,1);
	}else{
		lua_pushnumber(L,0);
	}
	lua_pushnumber(L,number1);
	lua_pushnumber(L,number2);
  return 3;
}

//luaL_Reg结构体的第一个字段为字符串，在注册时用于通知Lua该函数的名字。
//第一个字段为C函数指针。
//结构体数组中的最后一个元素的两个字段均为NULL，用于提示Lua注册函数已经到达数组的末尾。
static const luaL_Reg crclib[] = {
    {"getCRC16", getCRC16},
    {"b_and", b_and},
    {NULL, NULL} 
}; 

//该C库的唯一入口函数。其函数签名等同于上面的注册函数。见如下几点说明：
//1. 我们可以将该函数简单的理解为模块的工厂函数。
//2. 其函数名必须为luaopen_xxx，其中xxx表示library名称。Lua代码require "xxx"需要与之对应。
//3. 在luaL_register的调用中，其第一个字符串参数为模块名"xxx"，第二个参数为待注册函数的数组。
//4. 需要强调的是，所有需要用到"xxx"的代码，不论C还是Lua，都必须保持一致，这是Lua的约定，
//   否则将无法调用。
int luaopen_crclib(lua_State* L)
{
    const char* libName = "crclib";
    luaL_register(L,libName,crclib);//lua5.1 version
    //luaL_newlib(L, crclib);//lua5.2 version
	//luaI_openlib(L, "crclib", crclib, 0);
    return 1;
}