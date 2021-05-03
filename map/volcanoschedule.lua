local WarnQuakeScheduleLong =
{
	{segsprev = 8},
	{segsprev = 16}
}

local WarnQuakeScheduleShort =
{
	{segsprev = 2},
	{segsprev = 4}
}

--The schedule used in dry season
local VolcanoDrySeasonSchedule =
{
	{-------------------------------------------erupt 1
		days = 3, --day61
		segs = 3,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 1,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 5,
			smoke_delay = 1,
			smoke_duration = 4,
		},
		warnquake =
		{
			{segsprev = 16, size="small"},
			{segsprev = 8, size="med"},
			{segsprev = 4, size="large"}
		}
	},
	{------------------------------------------------------erupt 2
		days = 2, --day63
		segs = 6,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 1,
			firerain_per_sec = .5, 
			ash_delay = 1,
			ash_duration = 5,
			smoke_delay = 1,
			smoke_duration = 4,
		},
		warnquake =
		{
			{segsprev = 16, size="small"},
			{segsprev = 8, size="med"},
			{segsprev = 4, size="large"}
		}
	},
	{--------------------------------------------erupt3

		days = 1, ---day65
		segs = 10,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 2,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 6,
			smoke_delay = 1,
			smoke_duration = 5,
		},
		warnquake =
		{
			{segsprev = 16, size="small"},
			{segsprev = 8, size="med"},
			{segsprev = 4, size="large"}
		}
	},
	{----------------------------------------erupt 4
		days = 1,  --day66
		segs = 5,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 2,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 7,
			smoke_delay = 1,
			smoke_duration = 6,
		},
		warnquake =
		{
			{segsprev = 16, size="small"},
			{segsprev = 8, size="med"},
			{segsprev = 4, size="large"}
		}
	},
	{-----------------------------------------------erupt 5
		days = 1, --day 67
		segs = 8,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,--5 seconds
			ash_delay = 1,
			ash_duration = 8,
			smoke_delay = 1,
			smoke_duration = 7,
		},
		warnquake =
		{
			{segsprev = 16, size="small"},
			{segsprev = 8, size="med"},
			{segsprev = 4, size="large"}
		}
	},
	{-------------------------------------------------------erupt6
		days = 1, --day 68
		segs = 4,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,-- 4 seconds
			ash_delay = 1,
			ash_duration = 8,
			smoke_delay = 1,
			smoke_duration = 7,
		},
		warnquake =
		{
			{segsprev = 16, size="small"},
			{segsprev = 8, size="med"},
			{segsprev = 4, size="large"}
		}
	},
	{-----------------------------------------------erupt7
		days = 1, --day69
		segs = 8,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 16, size="small"},
			{segsprev = 8, size="med"},
			{segsprev = 4, size="large"}
		}
	},
	{---------------------------------------------erupt8
		days = 1, --day69
		segs = 4,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 12, size="small"},
			{segsprev = 6, size="med"},
			{segsprev = 2, size="large"}
		}
	},
	{----------------------------------------ERUPT 9
		days = 1,
		segs = 2,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 4, size="small"},
			{segsprev = 2, size="med"},
			{segsprev = 1, size="large"}
		}
	},
	{-----------------------------------erupt 10
		days = 0,
		segs = 14,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 4, size="small"},
			{segsprev = 2, size="med"},
			{segsprev = 1, size="large"}
		}
	},
	{------------------------------------------erupt 11
		days = 0,
		segs = 11,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 4, size="small"},
			{segsprev = 2, size="med"},
			{segsprev = 1, size="large"}
		}
	},
	{---------------------------------------------erupt 12
		days = 0,
		segs = 9,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 4, size="small"},
			{segsprev = 2, size="med"},
			{segsprev = 1, size="large"}
		}
	},
	{-------------------------------------------erupt 13
		days = 0,
		segs = 8,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,--
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 4, size="small"},
			{segsprev = 2, size="med"},
			{segsprev = 1, size="large"}
		}
	},
	{-----------------------------------------erupt 14
		days = 0,
		segs = 8,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 4, size="small"},
			{segsprev = 2, size="med"},
			{segsprev = 1, size="large"}
		}
	},
	{---------------------------------------erupt15
		days = 0,
		segs = 8,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = 1,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 4, size="small"},
			{segsprev = 2, size="med"},
			{segsprev = 1, size="large"}
		}
	},
	{---------------------------------------erupt16
		days = 0,
		segs = 8,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = 1,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 4, size="small"},
			{segsprev = 2, size="med"},
			{segsprev = 1, size="large"}
		}
	},

{---------------------------------------erupt16
		days = 0,
		segs = 8,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 3,
			firerain_per_sec = 1,
			ash_delay = 1,
			ash_duration = 9,
			smoke_delay = 1,
			smoke_duration = 8,
		},
		warnquake =
		{
			{segsprev = 4, size="small"},
			{segsprev = 2, size="med"},
			{segsprev = 1, size="large"}
		}
	},

}

--The schedule used for the Volcano Staff trap
local VolcanoStaffTrapSchedule =
{
	{
		days = 0,
		segs = 1,
		data =
		{
			firerain_delay = 0,
			firerain_duration = 1,
			firerain_per_sec = .5,
			ash_delay = 1,
			ash_duration = 5,
			smoke_delay = 1,
			smoke_duration = 4,
		},
		warnquake =
		{
			{segsprev = 1, size="large"}
		}
	},
}

return {DrySeasonSchedule = VolcanoDrySeasonSchedule, StaffTrapSchedule = VolcanoStaffTrapSchedule}