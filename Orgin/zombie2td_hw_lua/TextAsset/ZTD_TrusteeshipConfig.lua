local trusteeshipConfig = { }
trusteeshipConfig =
{
	{
		-- 上限保护范围(单位:百分比)
		highMaxRate = 200;
		highMinRate = 101;
		
		-- 下限保护范围(单位:百分比)
		lowMaxRate = 99;
		lowMinRate = 1;		
		
		-- 时间保护范围(单位:小时)
		timeMaxRate = 24;
		timeMinRate = 0.5;
		
		-- 帮助文本描述:
		helpDesc = 
		[[
1、拖拽进度条，可自行勾选所需的挂机保护，并自由调节所需的保护值设定；

2、通过点击对应挂机保护后方的开关按钮，可以自由选择是否开放对应保护；

3、上限保护最高可设置为当前金币库存的200%，最低可设置为当前金币库存的101%；

4、下限保护最高可设置为当前金币库存的99%，最低可设置为当前金币库存的1%；

5、时间保护最高可以设置为24小时，最低可设置为0.5小时。
		]];
		
		-- 结算页面中的特殊图标处理，type含义需要能和服务器对应
		-- 5:战火异鬼怪奖金池		
		exTypeIcon5 = "zhangdou-long.png";
		-- 6:合体技获得的金币
		exTypeIcon6 = "zhangdou-combskill.png";
	}
}

return trusteeshipConfig