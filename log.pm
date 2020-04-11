package log;
use strict;
use Sys::Hostname;
use Carp;
use Data::Dumper;
$Data::Dumper::Terse = 1;
use File::Basename;

use Term::ANSIColor;

my $login = getlogin();
my $currentScriptName   = basename($0);
my $writeLog            = ">>/home/$login/no_depot/log/$currentScriptName.log";
my $dirLog              = "/home/$login/no_depot/log/";

sub debug
{
    log::_log('debug', @_);
}

sub warn
{
    log::_log('warn', @_);
}

sub critical
{
    log::_log('critical', @_);
}

sub info
{
    log::_log('info', @_);
}

sub log
{
    log::_log('log', @_);
}

sub _log
{
    my $level = shift;
    my (%params) = @_;

    my $date    = `date "+%Y-%m-%d %H:%M:%S"`;
    chomp ($date);

    if(-e $dirLog and not -d $dirLog)
    {
        warn("'$dirLog' is not directory");
    }
    elsif(not -d $dirLog)
    {
        my $fnret = system("mkdir -p $dirLog");
        if($fnret)
        {
            warn("Save log impossible to $dirLog");
        }
    }

    my $saveTheLog = 0;
    if( -d $dirLog)
    {
        if(!open LOGFILE, $writeLog)
        {
            warn("$date - [ERROR] Failed to open file", $!);
        }
        else
        {
            $saveTheLog = 1;
        }

    }
    my $color       = 0;

    if(ref ($level) eq '' and $level =~ /^warn$/i )
    {
        $level   = 'WARN';
        $color   = 'yellow';
    }
    elsif(ref ($level) eq '' and $level =~ /^critical$/i )
    {
        $level   = 'CRITICAL';
        $color   = 'red';
    }
    elsif(ref ($level) eq '' and $level =~ /^info$/i )
    {
        $level   = 'INFO';
        $color   = 'reset';
    }
    elsif(ref ($level) eq '' and $level =~ /^log$/i )
    {
        $level   = 'LOG';
        $color   = 'green';
    }
    elsif(ref ($level) eq '' and $level =~ /^debug$/i )
    {
        $level   = 'DEBUG';
        $color   = 'reset';
    }
    elsif(not ref ($level))
    {
        warn('method use log deprecate');
        my $msg = $level;
        $level  = 'LOG';
        $color  = 'green';
        colorMyLog(
            msg    => sprintf("[%-9s- %1s] %1s \n", $level , $currentScriptName , $msg), 
            color  => $color,
        );
        $saveTheLog and print LOGFILE color("$color"), sprintf("[%-9s- %1s- %1s] %0s \n", $level, $currentScriptName, $date , $msg), color("reset");
    }
    else
    {
        warn('method use log deprecate');
        my $msg = Dumper($level);
        $level  = 'LOG';
        $color  = 'green';
        colorMyLog(
            msg    => sprintf("[%-9s- %1s] ", $level , $currentScriptName),
            color  => $color,
        );
        colorMyLog(
            msg    => $msg,
            color  => $color,
        );
        $saveTheLog and print LOGFILE color("$color"), sprintf("[%-9s- %1s- %1s] %0s \n", $level, $currentScriptName, $date , $msg), color("reset");
    }

    foreach my $param (%params)
    {
        if(not $param)
        {
            next;
        }

        my $string = Dumper($param);
        if(ref ($param))
        {
            my $refParams = ref ($param);
            #### Print Console ####
            colorMyLog(
                msg    => sprintf("[%-9s- %1s] %0s:", $level , $currentScriptName,$refParams),
                color  => $color,
            );

            colorMyLog(
                msg    => $string,
                color  => $color,
            );
            #### Save Log ####
            $saveTheLog and print LOGFILE color("$color"), sprintf("[%-9s- %1s- %1s] %0s", $level, $currentScriptName, $date , $string), color("reset");
        }
        else
        {
            #### Print Console ####
            colorMyLog(
                msg    => sprintf("[%-9s- %1s] %1s \n", $level , $currentScriptName , $param),
                color  => $color,
            );
            #### Save Log ####
            $saveTheLog and print LOGFILE  color("$color"), sprintf("[%-9s- %1s- %1s] %0s \n", $level, $currentScriptName, $date , $param), color("reset");
        }
    }
    close LOGFILE;
}

sub colorMyLog
{
    my (%params) = @_;
    my $msg     = $params{msg};
    my $color   = $params{color};
    
    print color("$color"), $msg , color("reset");
}
1;
