Config = {}

Config.Debug = false

-- Jobs that bypass safe zone restrictions
Config.ExemptJobs = {
    'police',
    'fire',
    'ambulance',
    'sheriff',
    'swat',
}

Config.NotifyOnEnter = true
Config.NotifyOnExit  = true

-- Default height half-extent when not specified (e.g. ±10 units from center Z)
Config.DefaultHeightRange = 10.0