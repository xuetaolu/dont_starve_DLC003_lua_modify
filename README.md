# dont_starve_DLC003_lua_modify

# 安装方法
备份饥荒 \dont_starve\data\DLC003\scripts 的lua脚本，
下载后替换掉 \dont_starve\data\DLC003\scripts 的lua脚本。

# 说明
饥荒 DLC003 哈姆雷特lua代码魔改，可以玩巨人国/海难，需勾选兼容哈姆雷特，启用DLC003的代码
`
-- file: dont_starve\data\DLC0003\scripts\stategraphs\SGwilson.lua

global("__xue__")
__xue__ = __xue__ or {}
-- 默认玩家可以攻击生效后立即移动，重置攻击，走A加速攻击
__xue__.CAN_CANCEL_ATTACK = true

-- 默认玩家不能在攻击生效前移动取消攻击
__xue__.CAN_CANCEL_ATTACK_ANYTIME = false

-- 默认玩家自动走A，需配合 CAN_CANCEL_ATTACK = true
__xue__.AUTO_CANCEL = true

-- 加速砍树，类似黑色行为学的加速工作
__xue__.FAST_CHOP = true

-- 默认玩家加速攻击 8 帧，秒打
__xue__.FAST_ATTACK_TIME = 8*FRAMES+0.01

-- 默认玩家攻击有击退，为 1，大约打退1.5格草叉距离
__xue__.KNOCK_BACK_MULTI = 1

-- 默认玩家被打硬直时间缩短 3 帧，原本就是 3 帧，即没有硬直
__xue__.ANTI_HIT_TIME = 3*FRAMES

-- 敌人加速攻击动作，调 30 差不多都是秒打
__xue__.ENEMY_MULTI_ATTACK_SPEED = 3

-- 其他
-- 敌人可以移动攻击，边走边打你
`
