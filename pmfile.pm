package GitHub_Collector;
use base 'Collector';

use strict;
use LWP::Simple;
use HTTP::Request;
use YAML::Tiny;
use File::Find; 


sub initialize
{
  
  return 1;
}

sub status
{

my $sub_directory;
my $newdir;
my @log;
my $path1;
my $path2;
my @shortlog;
my $count;
my @dir_list;
my $length;
#my $currdir;
#===============================================================================================================
# Change to specified local GitHub repository which has all local repository
#===============================================================================================================
chdir($_[0]) or die "ERROR: Directory: \"$_[0]\" does not exist.\n";									

#===============================================================================================================
# List all files/repositories
#================================================================================================================	
@dir_list=`dir /b`	or die "ERROR : No subdirectories in the specified directory $_[0]\n";
$length=@dir_list;
if ($length==0)
{
die "ERROR : No subdirectories in the specified directory $_[0]\n";
}	
#================================================================================================================
# For each of the listed directories
#================================================================================================================
foreach $sub_directory(@dir_list)
{																									
chomp($sub_directory);
print "\n\n#####################################################################\n";
print "####    		 REPOSITORY $sub_directory   	  		 ####\n";
print "#####################################################################\n";

$newdir=join('\\',$_[0],$sub_directory);

#=================================================================================================================
# Move into each repository to check the status
#=================================================================================================================
chdir ($newdir) or die "Directory $newdir does not exist\n";										

#=================================================================================================================
# Execute command "git status --porcelain" to get status in an easy-to-parse format for scripts.
# The command gives short output. That is the output is not verbose
# Array @log will contain the output of the command
#=================================================================================================================

@log=`git status --porcelain --ignored` or die "ERROR: $_[0] is not a Git repository!\n";	
$length	=@log;
print "\nWORK TREE STATUS:\n";	
#print "log is : @log\n";
#=================================================================================================================
# If the length of the array is zero then give a verbose status using command "git status -v"
#=================================================================================================================
if ($length==0)
{
system('git status -v') or die "ERROR: $_[0] is not a Git repository!\n";	
goto COMMITCOUNT;
}		

#=================================================================================================================
# For each entry in the array @log, check the status code of the listed files and print the corresponding status
# the command prints the status of each path as 
# XY PATH1 -> PATH2
# where PATH1 is the path in the HEAD, and the " -> PATH2" part is shown only when PATH1 corresponds to a
# different path in the index/worktree (i.e. the file is renamed). The XY is a two-letter status code.
#=================================================================================================================
foreach (@log)
{
if ($_=~/[ MADRCU?!][ MADRCU?!] +([\d\D\.-_]+)+ *\-?\>? *([\d\D\.-_]*)?/)
{
chomp($path1=$1);
chomp($path2=$2);

}
else 
{
print "no pattern match\n";
}

if ($_=~/^M[ MD]/)
{
print "File $path1 has been UPDATED in index.\n";																						
}elsif ($_=~/^A[ MD]/)
{
print "File $path1 has been ADDED to index but not commited.\n";																					
}elsif ($_=~/^D[ M]/)
{
print "File $path1 has been DELETED from index.\n";																						
}elsif ($_=~/^R[ MD]/)
{
print "File $path1 has been RENAMED in index.\n";																					
}elsif ($_=~/^C[ MD]/)
{
print "File $path1 has been COPIED in index.\n";																						
}elsif ($_=~/^[MARC] /)
{
print "index AND WORKTREE of file $path1 MATCHES.\n";																					
}elsif ($_=~/^[MARC]M/)
{
print "WORKTREE of the file $path1 has been CHANGED since index.\n";																					
}elsif ($_=~/^[MARC]D/)
{
print "The file $path1 has been DELETED in WORKTREE.\n";																			
}elsif ($_=~/^DD/)
{
print "File $path1 and $path2 has been UNMERGED AND BOTH  DELETED.\n";																				
}elsif ($_=~/^AU/)
{
print "File $path1 has been UNMERGED AND ADDED BY US.\n";																					
}elsif ($_=~/^UD/)
{
print "File $path1 has been UNMERGED AND DELETED BY THEM.\n";																					
}elsif ($_=~/^UA/)
{
print "File $path1 has been UNMERGED AND ADDED BY THEM.\n";																					
}elsif ($_=~/^DU/)
{
print "File $path1 has been UNMERGED AND DELETED BY US.\n";																							
}elsif ($_=~/^AA/)
{
print "File $path1 has been UNMERGED, both ADDED.\n";																						
}elsif ($_=~/^UU/)
{
print "File $path1 has been UNMERGED, both MODIFIED.\n";																							
}elsif ($_=~/^\?\?/)
{
print "File $path1 is UNTRACKED.\n";																						
}elsif ($_=~/^!!/)
{
print "File $path1 and $path2 has been UNMERGED, both ADDED\n";																						
}elsif ($_=~/^ M/)
{
print "File $path1 has been  MODIFIED.\n";																							
}elsif ($_=~/^ D/)
{
print "File $path1 has been DELETED.\n";																							
}
else{
print "NO UPDATES!\n";
}
}
COMMITCOUNT:
#====================================================================================================
# The command "git shortlog -sn" shows a list of contributors ordered by number of commits. 
# Array shortlog has total number of commits by each user
#====================================================================================================
@shortlog=`git shortlog -sn` or die "ERROR : COMMAND FAILED.. HAVE YOU INSTALLED GIT IN YOUR SYSTEM?\n";																			
$length=@shortlog;


$count=0;
foreach (@shortlog)
{
if ($_=~/([0-9]+)/)									
{
#===================================================================================================
# Add commits of each contributer
#===================================================================================================
$count+=$1;																							
}
}
#===================================================================================================
# Print number of commits
#===================================================================================================
print "\n\nNUMBER OF COMMITS ARE: $count\n";	

if ($length>1){
print "\nWARNING: MULTIPLE USERS HAVE COMMITTED IN THE THIS REPOSITORY\n";
}
	

chdir ("..") or die "Error in cd ... \n";
}

}


sub availability
{

my $ua;
my $target;
my $start;
my $request;
my $response;
my $time;


print "\n#####################################################################\n\n";
	#====================================================================
	# Set response limit in seconds
	#====================================================================																	
	$ua = LWP::UserAgent->new;
	$ua->proxy(['http', 'ftp','https'], 'http://autocache.hp.com/');
	$target="http://github.com/";
	
	#====================================================================
	# HTTP GET request
	#====================================================================
	$request=HTTP::Request->new(GET => "$target"); 		
	
	#====================================================================
	# Start timer
	#====================================================================
	$start=time;																		
	$response=$ua->request($request);
	
	#====================================================================
	# Check if the GET request is a success
	#====================================================================
	if($response->is_success)
	{
	#====================================================================
	# Stop the timer and record the time time lapsed
	#====================================================================
		my $time = time;																	
		$time = ($time - $start); 
	
		if ($_[0] <= $time) 
		{	
	#====================================================================
	# Slow response from the site as lapsed time is greater then the 
	# respose time limit.
	#====================================================================		
             print "$target, SLOW, Response time: $time seconds\n";
        } 
		else {
				print "$target, ACCESSED, Response time: $time seconds\n"; 
			}
          
	}  
	#====================================================================
	# HTTP GET failed! Site is down!
	#====================================================================
	else { 																					
			print "$target is DOWN." . $response->status_line . "\n";
		 }
print "\n#####################################################################\n\n\n";
	

}

sub repository_size
{   
my $dirsize;
# Recurse down into the directory. If a file is found then its size is calculated. if a subdirectory is found recurse down the sub directory.

find(sub { $dirsize += -s if -f $_ }, $_[0]); 
print "\n\n#####################################################################\n";
print "\nLOCAL REPOSITORY SIZE IS:  $dirsize Bytes\n";
$dirsize=$dirsize/1024;
print "OR  $dirsize Kilo Bytes\n";
print "\n#####################################################################\n\n\n";
find(\&checksize, $_[0]);
}
sub checksize
{
if ((-f $_)  && (!($_=~/^[\d\D-_.]{30,50}$/)))
{ 
my $size;
$size=(-s $_)/1024;
	if ($size >54)
	{
	print "\n\n#####################################################################\n\n";
	print "MAJOR WARNING: FILE $_ \nIN FOLDER:";
	system("chdir");
	print "HAS SIZE GREATER THAT 54KB in the \n";
	print "\n#####################################################################\n\n\n";
	}
	elsif ($size>=50)
	{
	print "\n#####################################################################\n";
	print "WARNING: FILE: $_ \nIN FOLDER:";
	system("chdir");
	print "HAS SIZE GREATER THAT 50KB in the \n";
	print "\n#####################################################################\n\n\n";
	}
	else{
	}
}
}
sub run
{
my $file;
my $response_limit;
my $gitdir;
$file=YAML::Tiny->read('GitHub_Collector.yml');

if (defined $file->[1]->{GitHub_Site_Response_Limit_in_seconds} && ($file->[1]->{GitHub_Site_Response_Limit_in_seconds}=~/^[0-9][0-9]?$/))
{
$response_limit=$file->[1]->{GitHub_Site_Response_Limit_in_seconds};
chomp($response_limit);
availability($response_limit);
}
else{
die "Please enter a valid two digit interger for \"GitHub_Site_Response_Limit_in_seconds\".\n";
}

if (defined $file->[1]->{Path_to_local_repository})
{
$gitdir=$file->[1]->{Path_to_local_repository};
chomp($gitdir);
status($gitdir);
repository_size($gitdir);
}
else{
die "Please enter a valid directory for \"Path_to_local_repository\".\n";
}

return 1;
}

sub topology
{
  return 1;
}
1;
