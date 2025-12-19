import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results", "item"]
  static values = { history: Array }

  connect() {
    this.close()
    
    // Close dropdown when clicking outside
    document.addEventListener("click", (e) => {
      if (!this.element.contains(e.target)) {
        this.close()
      }
    })
  }

  filter() {
    const query = this.inputTarget.value.toLowerCase()
    
    // If empty or focused, show filtered list (or full list if empty)
    if (this.historyValue.length === 0) {
      this.close()
      return
    }

    const matches = this.historyValue.filter(term => 
      term.toLowerCase().includes(query)
    )

    if (matches.length > 0) {
      this.open()
      this.renderResults(matches)
    } else {
      this.close()
    }
  }

  renderResults(matches) {
    this.resultsTarget.innerHTML = matches.map(term => {
      const safeTerm = this.escapeHTML(term)
      return `
      <li data-search-autocomplete-target="item"
          data-action="click->search-autocomplete#select"
          class="px-5 py-3 hover:bg-white/10 cursor-pointer text-gray-300 hover:text-white transition-colors border-b border-white/5 last:border-0"
          data-value="${safeTerm}">
        <div class="flex items-center gap-3">
           <svg class="w-4 h-4 text-purple-500 opacity-70" width="16" height="16" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"></path></svg>
           <span class="font-medium">${safeTerm}</span>
        </div>
      </li>
    `}).join("")
  }

  escapeHTML(str) {
    return str.replace(/[&<>'"]/g, 
      tag => ({
          '&': '&amp;',
          '<': '&lt;',
          '>': '&gt;',
          "'": '&#39;',
          '"': '&quot;'
        }[tag]));
  }

  select(event) {
    const term = event.currentTarget.dataset.value
    this.inputTarget.value = term
    this.close()
    // No need to call save() here, creating the submit event will trigger it via the form action
    this.element.requestSubmit() 
  }

  save() {
    const term = this.inputTarget.value.trim()
    if (!term) return

    // Optimistically update the history array in memory
    let history = this.historyValue
    // Remove if exists to move to top
    history = history.filter(t => t !== term)
    history.unshift(term)
    // Keep max 5
    this.historyValue = history.slice(0, 5)
  }

  open() {
    this.resultsTarget.classList.remove("hidden")
  }

  close() {
    this.resultsTarget.classList.add("hidden")
  }
}
