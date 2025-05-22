<%@ page session="true" isELIgnored="true" %>
<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page language="java" pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Hộp thư đến | Inbox</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 0;
      padding: 0;
      background-color: #f5f5f5;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      padding: 20px;
    }
    .header {
      background-color: #4285f4;
      color: white;
      padding: 15px;
      border-radius: 5px 5px 0 0;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .header h1 {
      margin: 0;
      font-size: 24px;
    }
    .controls {
      margin: 15px 0;
      display: flex;
      gap: 10px;
      align-items: center;
    }
    .btn {
      padding: 8px 16px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: bold;
      transition: background-color 0.3s;
    }
    .btn-primary {
      background-color: #4285f4;
      color: white;
    }
    .btn-primary:hover {
      background-color: #3367d6;
    }
    .btn-secondary {
      background-color: #f8f9fa;
      color: #3c4043;
      border: 1px solid #dadce0;
    }
    .btn-secondary:hover {
      background-color: #f1f3f4;
    }
    .btn:disabled {
      background-color: #dadce0;
      color: #80868b;
      cursor: not-allowed;
    }
    .language-selector {
      margin-left: auto;
    }
    .content {
      display: flex;
      height: 70vh;
      background-color: white;
      border-radius: 0 0 5px 5px;
      box-shadow: 0 1px 3px rgba(0,0,0,0.12);
    }
    .message-list {
      flex: 1;
      border-right: 1px solid #dadce0;
      overflow-y: auto;
    }
    .message-content {
      flex: 2;
      padding: 15px;
      overflow-y: auto;
    }
    ul#emails {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    ul#emails li {
      padding: 12px 15px;
      border-bottom: 1px solid #dadce0;
      cursor: pointer;
      transition: background-color 0.2s;
    }
    ul#emails li:hover {
      background-color: #f1f3f4;
    }
    ul#emails li.active {
      background-color: #e8f0fe;
      border-left: 4px solid #4285f4;
    }
    .email-subject {
      font-weight: bold;
      margin-bottom: 5px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    .email-snippet {
      color: #5f6368;
      font-size: 13px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    #content {
      white-space: pre-wrap;
      font-family: Arial, sans-serif;
      line-height: 1.5;
      padding: 10px;
    }
    .loading {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100%;
    }
    .loading-spinner {
      border: 4px solid #f3f3f3;
      border-top: 4px solid #4285f4;
      border-radius: 50%;
      width: 30px;
      height: 30px;
      animation: spin 1s linear infinite;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    .notification {
      padding: 10px;
      margin: 10px 0;
      border-radius: 4px;
      text-align: center;
    }
    .error {
      background-color: #fdecea;
      color: #c5221f;
      border: 1px solid #f5c2c0;
    }
    .empty-message {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 100%;
      color: #5f6368;
    }
    /* Pagination styles */
    .pagination {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .page-info {
      font-size: 14px;
      font-weight: bold;
      min-width: 60px;
      text-align: center;
    }
    .page-jump {
      display: flex;
      align-items: center;
      gap: 5px;
      margin-left: 10px;
    }
    .page-jump input {
      width: 40px;
      padding: 5px;
      border: 1px solid #dadce0;
      border-radius: 4px;
      text-align: center;
    }
    .page-jump button {
      padding: 5px 10px;
    }
  </style>
  <script>
    // Language strings
    const translations = {
      'en': {
        'inbox': 'Inbox',
        'refresh': 'Refresh',
        'compose': 'Compose',
        'loading': 'Loading emails...',
        'noEmails': 'No emails found',
        'errorLoading': 'Error loading emails',
        'errorContent': 'Error loading email content',
        'selectPrompt': 'Select an email to view its content',
        'prev': '« Previous',
        'next': 'Next »',
        'page': 'Page',
        'of': 'of',
        'go': 'Go',
        'goToPage': 'Go to page'
      },
      'vi': {
        'inbox': 'Hộp thư đến',
        'refresh': 'Làm mới',
        'compose': 'Soạn thư mới',
        'loading': 'Đang tải email...',
        'noEmails': 'Không tìm thấy email nào',
        'errorLoading': 'Lỗi khi tải email',
        'errorContent': 'Lỗi khi tải nội dung email',
        'selectPrompt': 'Chọn một email để xem nội dung',
        'prev': '« Trước',
        'next': 'Sau »',
        'page': 'Trang',
        'of': 'trên',
        'go': 'Đi đến',
        'goToPage': 'Đi đến trang'
      }
    };

    let currentLanguage = 'vi';

    function translate(key) {
      return translations[currentLanguage][key] || key;
    }

    function changeLanguage(lang) {
      currentLanguage = lang;
      updateUI();
    }

    function updateUI() {
      document.title = translate('inbox');
      document.querySelector('.header h1').textContent = translate('inbox');
      document.getElementById('refresh-btn').textContent = translate('refresh');
      document.getElementById('compose-link').textContent = translate('compose');
      document.getElementById('prev-btn').textContent = translate('prev');
      document.getElementById('next-btn').textContent = translate('next');
      document.getElementById('go-btn').textContent = translate('go');
      document.getElementById('jump-label').textContent = translate('goToPage');

      // Update content if it's the default prompt
      if (document.getElementById('content').classList.contains('select-prompt')) {
        document.getElementById('content').textContent = translate('selectPrompt');
      }

      // Update loading message if present
      const loadingEl = document.querySelector('.loading p');
      if (loadingEl) {
        loadingEl.textContent = translate('loading');
      }
    }

    // Pagination state
    let currentPage = 1;
    const pageSize = 10;
    let totalPages = 1;
    let totalEmails = 0;

    async function loadList(page = 1) {
      currentPage = page;
      const emailsList = document.getElementById('emails');
      emailsList.innerHTML = `<div class="loading"><div class="loading-spinner"></div><p>${translate('loading')}</p></div>`;
      emailsList.classList.add('loading');

      try {
        const res = await fetch(`api/list?page=${page}&size=${pageSize}`);
        if (!res.ok) throw new Error('HTTP error! status: ' + res.status);

        const data = await res.json();
        emailsList.classList.remove('loading');
        emailsList.innerHTML = '';

        // Update pagination info
        totalEmails = data.totalCount || 0;
        totalPages = Math.max(Math.ceil(totalEmails / pageSize), 1);
        document.getElementById('page-info').textContent = `${currentPage}/${totalPages}`;
        document.getElementById('prev-btn').disabled = currentPage <= 1;
        document.getElementById('next-btn').disabled = currentPage >= totalPages;
        document.getElementById('page-input').max = totalPages;
        document.getElementById('page-input').placeholder = currentPage;

        if (data.messages && data.messages.length > 0) {
          data.messages.forEach(m => {
            const li = document.createElement('li');
            li.setAttribute('data-id', m.id);
            let subject = "No Subject";
            if (m.payload && m.payload.headers) {
              const subjectHeader = m.payload.headers.find(h => h.name.toLowerCase() === 'subject');
              if (subjectHeader) subject = subjectHeader.value;
            }
            const snippet = m.snippet || "";
            li.innerHTML = `
              <div class="email-subject">${escapeHtml(subject)}</div>
              <div class="email-snippet">${escapeHtml(snippet)}</div>
            `;
            li.onclick = function() {
              document.querySelectorAll('#emails li').forEach(item => item.classList.remove('active'));
              this.classList.add('active');
              loadEmail(m.id);
            };
            emailsList.appendChild(li);
          });
        } else {
          emailsList.innerHTML = `<div class="empty-message"><p>${translate('noEmails')}</p></div>`;
        }
      } catch (error) {
        emailsList.classList.remove('loading');
        emailsList.innerHTML = `<div class="notification error"><p>${translate('errorLoading')}</p><p>${error.message}</p></div>`;
      }
    }

    async function loadEmail(id) {
      const contentDiv = document.getElementById('content');
      contentDiv.innerHTML = '<div class="loading"><div class="loading-spinner"></div></div>';
      contentDiv.classList.remove('select-prompt');

      try {
        const res = await fetch('api/get?id=' + encodeURIComponent(id));
        if (!res.ok) throw new Error('HTTP error! status: ' + res.status);
        const json = await res.json();
        contentDiv.innerText = json.body || "No content available";
      } catch (error) {
        contentDiv.innerHTML = `<div class="notification error"><p>${translate('errorContent')}</p><p>${error.message}</p></div>`;
      }
    }

    function escapeHtml(unsafe) {
      return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
    }

    function goToPage() {
      const pageInput = document.getElementById('page-input');
      let page = parseInt(pageInput.value);
      if (isNaN(page) || page < 1) {
        page = 1;
      } else if (page > totalPages) {
        page = totalPages;
      }
      loadList(page);
      pageInput.value = '';  // Clear input after use
    }

    window.onload = function() {
      updateUI();
      loadList();
      document.getElementById('lang-en').addEventListener('click', () => changeLanguage('en'));
      document.getElementById('lang-vi').addEventListener('click', () => changeLanguage('vi'));
      document.getElementById('prev-btn').addEventListener('click', () => loadList(currentPage - 1));
      document.getElementById('next-btn').addEventListener('click', () => loadList(currentPage + 1));
      document.getElementById('go-btn').addEventListener('click', goToPage);

      // Allow pressing Enter in the page input
      document.getElementById('page-input').addEventListener('keypress', function(e) {
        if (e.key === 'Enter') {
          goToPage();
        }
      });
    };
  </script>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>Hộp thư đến</h1>
      <div class="language-selector">
        <button id="lang-en" class="btn btn-secondary">English</button>
        <button id="lang-vi" class="btn btn-secondary">Tiếng Việt</button>
      </div>
    </div>

    <div class="controls">
      <button id="refresh-btn" class="btn btn-primary" onclick="loadList(currentPage)">Làm mới</button>
      <a id="compose-link" href="compose.jsp" class="btn btn-secondary">Soạn thư mới</a>
      <div class="pagination">
        <button id="prev-btn" class="btn btn-secondary" disabled>&laquo; Trước</button>
        <span class="page-info" id="page-info">1/1</span>
        <button id="next-btn" class="btn btn-secondary" disabled>Sau &raquo;</button>

        <div class="page-jump">
          <label id="jump-label" for="page-input">Đi đến trang</label>
          <input type="number" id="page-input" min="1" placeholder="1">
          <button id="go-btn" class="btn btn-secondary">Đi đến</button>
        </div>
      </div>
    </div>

    <div class="content">
      <div class="message-list">
        <ul id="emails">
          <div class="loading">
            <div class="loading-spinner"></div>
            <p>Đang tải email...</p>
          </div>
        </ul>
      </div>
      <div class="message-content">
        <pre id="content" class="select-prompt">Chọn một email để xem nội dung</pre>
      </div>
    </div>
  </div>
</body>
</html>