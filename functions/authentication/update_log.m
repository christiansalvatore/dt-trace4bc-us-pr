function update_log(varargin)

usr__ = varargin{1};
usr__ = crypting(usr__, 1, 0);
event = varargin{2};
local_license = varargin{3};
local = load(local_license);
log = local.log;
next_log = size(log,1)+1;
now_date = datetime('now');
log{next_log,1} = now_date;
log{next_log,2} = usr__;
log{next_log,3} = event;

save(local_license,'log','-append');