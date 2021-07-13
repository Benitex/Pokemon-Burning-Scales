#===============================================================================
#  Reads files of certain format from a directory
#===============================================================================
class Dir
  #-----------------------------------------------------------------------------
  #  Reads all files in a directory
  #-----------------------------------------------------------------------------
  def self.get(dir, filters = "*", full = true)
    files = []
    filters = [filters] if !filters.is_a?(Array)
    self.chdir(dir) do
      for filter in filters
        self.glob(filter){ |f| files.push(full ? (dir + "/" + f) : f) }
      end
    end
    return files.sort
  end
  #-----------------------------------------------------------------------------
  #  Generates entire file/folder tree from a certain directory
  #-----------------------------------------------------------------------------
  def self.all(dir, filters = "*", full = true)
    # sets variables for starting
    files = []
    subfolders = []
    for file in self.get(dir, filters, full)
      # engages in recursion to read the entire file tree
      if self.safe?(file)   # Is a directory
        subfolders += self.all(file, filters, full)
      else   # Is a file
        files += [file]
      end
    end
    # returns all found files
    return files + subfolders
  end
  #-----------------------------------------------------------------------------
  #  Checks for existing directory, gets around accents
  #-----------------------------------------------------------------------------
  def self.safe?(dir)
    return false if !FileTest.directory?(dir)
    ret = false
    self.chdir(dir) { ret = true } rescue nil
    return ret
  end
  #-----------------------------------------------------------------------------
end



#===============================================================================
#  extensions for file class
#===============================================================================
class File
  #-----------------------------------------------------------------------------
  #  Checks for existing file, gets around accents
  #-----------------------------------------------------------------------------
  def self.safe?(file)
    ret = false
    self.open(file, 'rb') { ret = true } rescue nil
    return ret
  end
  #-----------------------------------------------------------------------------
end



#===============================================================================
# Checking for files and directories
#===============================================================================
# Works around a problem with FileTest.directory if directory contains accent marks
def safeIsDirectory?(f)
  ret = false
  Dir.chdir(f) { ret = true } rescue nil
  return ret
end

# Works around a problem with FileTest.exist if path contains accent marks
def safeExists?(f)
  return FileTest.exist?(f) if f[/\A[\x20-\x7E]*\z/]
  ret = false
  begin
    File.open(f,"rb") { ret = true }
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES
    ret = false
  end
  return ret
end

# Similar to "Dir.glob", but designed to work around a problem with accessing
# files if a path contains accent marks.
# "dir" is the directory path, "wildcard" is the filename pattern to match.
def safeGlob(dir,wildcard)
  ret = []
  afterChdir = false
  begin
    Dir.chdir(dir) {
      afterChdir = true
      Dir.glob(wildcard) { |f| ret.push(dir+"/"+f) }
    }
  rescue Errno::ENOENT
    raise if afterChdir
  end
  if block_given?
    ret.each { |f| yield(f) }
  end
  return (block_given?) ? nil : ret
end

def pbResolveAudioSE(file)
  return nil if !file
  if RTP.exists?("Audio/SE/"+file,["",".wav",".mp3",".ogg"])
    return RTP.getPath("Audio/SE/"+file,["",".wav",".mp3",".ogg"])
  end
  return nil
end

# Finds the real path for an image file.  This includes paths in encrypted
# archives.  Returns nil if the path can't be found.
def pbResolveBitmap(x)
  return nil if !x
  noext = x.gsub(/\.(bmp|png|gif|jpg|jpeg)$/,"")
  filename = nil
#  RTP.eachPathFor(x) { |path|
#    filename = pbTryString(path) if !filename
#    filename = pbTryString(path+".gif") if !filename
#  }
  RTP.eachPathFor(noext) { |path|
    filename = pbTryString(path+".png") if !filename
    filename = pbTryString(path+".gif") if !filename
#    filename = pbTryString(path+".jpg") if !filename
#    filename = pbTryString(path+".jpeg") if !filename
#    filename = pbTryString(path+".bmp") if !filename
  }
  return filename
end

# Finds the real path for an image file.  This includes paths in encrypted
# archives.  Returns _x_ if the path can't be found.
def pbBitmapName(x)
  ret = pbResolveBitmap(x)
  return (ret) ? ret : x
end

def strsplit(str, re)
  ret = []
  tstr = str
  while re =~ tstr
    ret[ret.length] = $~.pre_match
    tstr = $~.post_match
  end
  ret[ret.length] = tstr if ret.length
  return ret
end

def canonicalize(c)
  csplit = strsplit(c, /[\/\\]/)
  pos = -1
  ret = []
  retstr = ""
  for x in csplit
    if x == ".."
      if pos >= 0
        ret.delete_at(pos)
        pos -= 1
      end
    elsif x != "."
      ret.push(x)
      pos += 1
    end
  end
  for i in 0...ret.length
    retstr += "/" if i > 0
    retstr += ret[i]
  end
  return retstr
end



module RTP
  @rtpPaths = nil

  def self.exists?(filename,extensions=[])
    return false if nil_or_empty?(filename)
    eachPathFor(filename) { |path|
      return true if safeExists?(path)
      for ext in extensions
        return true if safeExists?(path+ext)
      end
    }
    return false
  end

  def self.getImagePath(filename)
    return self.getPath(filename,["",".png",".gif"])   # ".jpg", ".jpeg", ".bmp"
  end

  def self.getAudioPath(filename)
    return self.getPath(filename,["",".mp3",".wav",".wma",".mid",".ogg",".midi"])
  end

  def self.getPath(filename,extensions=[])
    return filename if nil_or_empty?(filename)
    eachPathFor(filename) { |path|
      return path if safeExists?(path)
      for ext in extensions
        file = path+ext
        return file if safeExists?(file)
      end
    }
    return filename
  end

 # Gets the absolute RGSS paths for the given file name
  def self.eachPathFor(filename)
    return if !filename
    if filename[/^[A-Za-z]\:[\/\\]/] || filename[/^[\/\\]/]
      # filename is already absolute
      yield filename
    else
      # relative path
      RTP.eachPath { |path|
        if path=="./"
          yield filename
        else
          yield path+filename
        end
      }
    end
  end

  # Gets all RGSS search paths.
  # This function basically does nothing now, because
  # the passage of time and introduction of MKXP make
  # it useless, but leaving it for compatibility
  # reasons
  def self.eachPath
    # XXX: Use "." instead of Dir.pwd because of problems retrieving files if
    # the current directory contains an accent mark
    yield ".".gsub(/[\/\\]/,"/").gsub(/[\/\\]$/,"")+"/"
  end

  private

  def self.getSaveFileName(fileName)
    File.join(getSaveFolder, fileName)
  end

  def self.getSaveFolder
    # MKXP makes sure that this folder has been created
    # once it starts. The location differs depending on
    # the operating system:
    # Windows: %APPDATA%
    # Linux: $HOME/.local/share
    # macOS (unsandboxed): $HOME/Library/Application Support
    System.data_directory
  end
end



module FileTest
  Image_ext = ['.png', '.gif']   # '.jpg', '.jpeg', '.bmp',
  Audio_ext = ['.mp3', '.mid', '.midi', '.ogg', '.wav', '.wma']

  def self.audio_exist?(filename)
    return RTP.exists?(filename,Audio_ext)
  end

  def self.image_exist?(filename)
    return RTP.exists?(filename,Image_ext)
  end
end



# Used to determine whether a data file exists (rather than a graphics or
# audio file). Doesn't check RTP, but does check encrypted archives.

# Note: pbGetFileChar checks anything added in MKXP's RTP setting,
# and matching mount points added through System.mount
def pbRgssExists?(filename)
  if safeExists?("./Game.rgssad")
    return pbGetFileChar(filename)!=nil
  else
    filename = canonicalize(filename)
    return safeExists?(filename)
  end
end

# Opens an IO, even if the file is in an encrypted archive.
# Doesn't check RTP for the file.

# Note: load_data checks anything added in MKXP's RTP setting,
# and matching mount points added through System.mount
def pbRgssOpen(file,mode=nil)
  #File.open("debug.txt","ab") { |fw| fw.write([file,mode,Time.now.to_f].inspect+"\r\n") }
  if !safeExists?("./Game.rgssad")
    if block_given?
      File.open(file,mode) { |f| yield f }
      return nil
    else
      return File.open(file,mode)
    end
  end
  file = canonicalize(file)
  Marshal.neverload = true
  str = load_data(file, true)
  if block_given?
    StringInput.open(str) { |f| yield f }
    return nil
  else
    return StringInput.open(str)
  end
end

# Gets at least the first byte of a file. Doesn't check RTP, but does check
# encrypted archives.
def pbGetFileChar(file)
  canon_file = canonicalize(file)
  if !safeExists?("./Game.rgssad")
    return nil if !safeExists?(canon_file)
    return nil if file.last == '/'   # Is a directory
    begin
      File.open(canon_file, "rb") { |f| return f.read(1) }   # read one byte
    rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES, Errno::EISDIR
      return nil
    end
  end
  str = nil
  begin
    str = load_data(canon_file, true)
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES, Errno::EISDIR, RGSSError, MKXPError
    str = nil
  end
  return str
end

def pbTryString(x)
  ret = pbGetFileChar(x)
  return (ret!=nil && ret!="") ? x : nil
end

# Gets the contents of a file. Doesn't check RTP, but does check
# encrypted archives.

# Note: load_data will check anything added in MKXP's RTP setting,
# and matching mount points added through System.mount
def pbGetFileString(file)
  file = canonicalize(file)
  if !safeExists?("./Game.rgssad")
    return nil if !safeExists?(file)
    begin
      File.open(file,"rb") { |f| return f.read }   # read all data
    rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES
      return nil
    end
  end
  str = nil
  begin
    str = load_data(file, true)
  rescue Errno::ENOENT, Errno::EINVAL, Errno::EACCES, RGSSError, MKXPError
    str = nil
  end
  return str
end



#===============================================================================
#
#===============================================================================
class StringInput
  include Enumerable

  class << self
    def new( str )
      if block_given?
        begin
          f = super
          yield f
        ensure
          f.close if f
        end
      else
        super
      end
    end
    alias open new
  end

  def initialize( str )
    @string = str
    @pos = 0
    @closed = false
    @lineno = 0
  end

  attr_reader :lineno,:string

  def inspect
    return "#<#{self.class}:#{@closed ? 'closed' : 'open'},src=#{@string[0,30].inspect}>"
  end

  def close
    raise IOError, 'closed stream' if @closed
    @pos = nil
    @closed = true
  end

  def closed?; @closed; end

  def pos
    raise IOError, 'closed stream' if @closed
    [@pos, @string.size].min
  end

  alias tell pos

  def rewind; seek(0); end

  def pos=(value); seek(value); end

  def seek(offset, whence=IO::SEEK_SET)
    raise IOError, 'closed stream' if @closed
    case whence
    when IO::SEEK_SET then @pos = offset
    when IO::SEEK_CUR then @pos += offset
    when IO::SEEK_END then @pos = @string.size - offset
    else
      raise ArgumentError, "unknown seek flag: #{whence}"
    end
    @pos = 0 if @pos < 0
    @pos = [@pos, @string.size + 1].min
    offset
  end

  def eof?
    raise IOError, 'closed stream' if @closed
    @pos > @string.size
  end

  def each( &block )
    raise IOError, 'closed stream' if @closed
    begin
      @string.each(&block)
    ensure
      @pos = 0
    end
  end

  def gets
    raise IOError, 'closed stream' if @closed
    if idx = @string.index(?\n, @pos)
      idx += 1  # "\n".size
      line = @string[ @pos ... idx ]
      @pos = idx
      @pos += 1 if @pos == @string.size
    else
      line = @string[ @pos .. -1 ]
      @pos = @string.size + 1
    end
    @lineno += 1
    line
  end

  def getc
    raise IOError, 'closed stream' if @closed
    ch = @string[@pos]
    @pos += 1
    @pos += 1 if @pos == @string.size
    ch
  end

  def read( len = nil )
    raise IOError, 'closed stream' if @closed
    if !len
      return nil if eof?
      rest = @string[@pos ... @string.size]
      @pos = @string.size + 1
      return rest
    end
    str = @string[@pos, len]
    @pos += len
    @pos += 1 if @pos == @string.size
    str
  end

  def read_all; read(); end

  alias sysread read
end
