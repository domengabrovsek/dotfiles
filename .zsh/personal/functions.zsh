# ============================================================================
# Personal-Specific Functions
# ============================================================================
# Custom functions specific to personal environment

# ============================================================================
# Project Management Functions
# ============================================================================

# Example: Create new project with standard structure
# new_project() {
#   if [[ -z "$1" ]]; then
#     echo "Usage: new_project <project_name>"
#     return 1
#   fi
#
#   local project_name="$1"
#   local project_dir="$HOME/projects/$project_name"
#
#   echo "🚀 Creating new project: $project_name"
#
#   mkdir -p "$project_dir"
#   cd "$project_dir"
#
#   # Initialize git
#   git init
#
#   # Create basic structure
#   mkdir -p src docs tests
#
#   # Create README
#   echo "# $project_name\n\nProject description here." > README.md
#
#   # Create .gitignore
#   echo "node_modules/\n.env\n.DS_Store\ndist/\nbuild/\n*.log" > .gitignore
#
#   echo "✅ Project created at: $project_dir"
# }

# ============================================================================
# Learning & Development Functions
# ============================================================================

# Example: Quick note-taking function
# note() {
#   local notes_dir="$HOME/Documents/notes"
#   local date=$(date +%Y-%m-%d)
#   local note_file="$notes_dir/$date.md"
#
#   mkdir -p "$notes_dir"
#
#   if [[ -z "$1" ]]; then
#     # Open today's note in editor
#     ${EDITOR} "$note_file"
#   else
#     # Append quick note
#     echo "- $(date +%H:%M): $*" >> "$note_file"
#     echo "✅ Note added to $note_file"
#   fi
# }

# Example: Create a learning playground for a new technology
# learn() {
#   if [[ -z "$1" ]]; then
#     echo "Usage: learn <technology_name>"
#     return 1
#   fi
#
#   local tech="$1"
#   local learn_dir="$HOME/projects/learning/$tech"
#
#   mkdir -p "$learn_dir"
#   cd "$learn_dir"
#
#   echo "# Learning $tech\n\nNotes and experiments.\n\n## Resources\n-\n\n## Notes\n-" > README.md
#
#   echo "📚 Learning environment created for: $tech"
# }

# ============================================================================
# Media & File Management Functions
# ============================================================================

# Example: Organize downloads folder
# organize_downloads() {
#   local downloads="$HOME/Downloads"
#   local docs="$HOME/Documents/FromDownloads"
#   local pics="$HOME/Pictures/FromDownloads"
#   local videos="$HOME/Videos/FromDownloads"
#
#   mkdir -p "$docs" "$pics" "$videos"
#
#   echo "🗂️  Organizing downloads..."
#
#   # Move PDFs and documents
#   find "$downloads" -maxdepth 1 -type f \( -name "*.pdf" -o -name "*.doc" -o -name "*.docx" \) -exec mv {} "$docs" \;
#
#   # Move images
#   find "$downloads" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.gif" \) -exec mv {} "$pics" \;
#
#   # Move videos
#   find "$downloads" -maxdepth 1 -type f \( -name "*.mp4" -o -name "*.mov" -o -name "*.avi" \) -exec mv {} "$videos" \;
#
#   echo "✅ Downloads organized!"
# }

# ============================================================================
# System Maintenance Functions
# ============================================================================

# Example: macOS system cleanup
# mac_cleanup() {
#   echo "🧹 Starting macOS cleanup..."
#
#   # Clear system caches (requires sudo)
#   echo "Clearing system caches..."
#   sudo rm -rf /Library/Caches/*
#   rm -rf ~/Library/Caches/*
#
#   # Clear DNS cache
#   echo "Flushing DNS cache..."
#   sudo dscacheutil -flushcache
#   sudo killall -HUP mDNSResponder
#
#   # Empty trash
#   echo "Emptying trash..."
#   rm -rf ~/.Trash/*
#
#   # Cleanup homebrew
#   if command -v brew &> /dev/null; then
#     echo "Cleaning up Homebrew..."
#     brew cleanup -s
#     brew autoremove
#   fi
#
#   # Cleanup Docker
#   if command -v docker &> /dev/null; then
#     echo "Cleaning up Docker..."
#     docker system prune -f
#   fi
#
#   # Cleanup Node
#   if command -v npm &> /dev/null; then
#     echo "Cleaning npm cache..."
#     npm cache clean --force
#   fi
#
#   echo "✨ Cleanup complete!"
# }

# ============================================================================
# Backup Functions
# ============================================================================

# Example: Backup important directories
# backup_personal() {
#   local backup_dest="/Volumes/Backup"  # Change to your backup location
#   local timestamp=$(date +%Y%m%d)
#
#   if [[ ! -d "$backup_dest" ]]; then
#     echo "❌ Backup destination not found: $backup_dest"
#     return 1
#   fi
#
#   echo "💾 Starting personal backup..."
#
#   # Backup projects
#   rsync -av --progress ~/projects "$backup_dest/projects-$timestamp"
#
#   # Backup documents
#   rsync -av --progress ~/Documents "$backup_dest/documents-$timestamp"
#
#   # Backup dotfiles
#   rsync -av --progress ~/.zshrc ~/.zsh "$backup_dest/dotfiles-$timestamp"
#
#   echo "✅ Backup complete!"
# }

# ============================================================================
# Fun Functions
# ============================================================================

# Example: Random tech quote
# tech_quote() {
#   local quotes=(
#     "\"Any fool can write code that a computer can understand. Good programmers write code that humans can understand.\" - Martin Fowler"
#     "\"First, solve the problem. Then, write the code.\" - John Johnson"
#     "\"Code is like humor. When you have to explain it, it's bad.\" - Cory House"
#     "\"Make it work, make it right, make it fast.\" - Kent Beck"
#   )
#
#   echo ${quotes[$RANDOM % ${#quotes[@]}]}
# }
