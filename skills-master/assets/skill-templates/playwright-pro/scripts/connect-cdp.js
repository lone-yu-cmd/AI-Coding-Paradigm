/**
 * Playwright Pro - CDP 连接与页面分析脚本
 * 
 * 功能：连接到已启动的调试版浏览器，分析页面的 DOM 结构、交互元素、CSS 样式、
 *       网络请求、Console 日志和性能指标
 * 
 * 使用方法：
 *   node connect-cdp.js [pageIndex|--url <keyword>] [selector1] [selector2] ...
 * 
 * 参数：
 *   pageIndex                - 要分析的标签页索引（默认为 0）
 *   --url <keyword>          - 通过 URL 关键字模糊匹配标签页
 *   --no-network             - 跳过网络请求捕获
 *   --no-console             - 跳过 Console 日志捕获
 *   --no-perf                - 跳过性能指标采集
 *   --network-wait <seconds> - 网络请求捕获等待时间（默认：5秒）
 *   selector1, selector2     - 要分析样式的 CSS 选择器（可选）
 * 
 * 环境变量：
 *   DEBUG_OUTPUT_DIR - 输出目录路径（默认：./debug-output）
 *   CDP_PORT - Chrome 调试端口（默认：9222）
 * 
 * 输出文件（在 debug-output 目录）：
 *   - screenshot.png              - 视口截图
 *   - screenshot-full.png         - 全页截图
 *   - style-report.md             - 样式分析报告
 *   - dom-tree.txt                - DOM 结构树
 *   - page-data.json              - 完整数据
 *   - accessibility-snapshot.json - 无障碍快照
 *   - network-requests.json       - 网络请求日志
 *   - console-logs.json           - Console 日志
 *   - performance-metrics.json    - 性能指标
 * 
 * 依赖：
 *   - playwright
 *   - 浏览器需要以 --remote-debugging-port 启动
 */

import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// 获取当前文件目录（跨平台兼容）
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// =============================================================================
// 参数解析
// =============================================================================

function parseArgs() {
  const args = process.argv.slice(2);
  const config = {
    pageIndex: 0,
    urlKeyword: null,
    selectors: [],
    captureNetwork: true,
    captureConsole: true,
    capturePerf: true,
    networkWait: 5,
  };

  let i = 0;
  while (i < args.length) {
    const arg = args[i];
    if (arg === '--url') {
      config.urlKeyword = args[++i];
    } else if (arg === '--no-network') {
      config.captureNetwork = false;
    } else if (arg === '--no-console') {
      config.captureConsole = false;
    } else if (arg === '--no-perf') {
      config.capturePerf = false;
    } else if (arg === '--network-wait') {
      config.networkWait = parseInt(args[++i]) || 5;
    } else if (arg.startsWith('--')) {
      // 忽略未知 flag
    } else if (config.urlKeyword === null && /^\d+$/.test(arg)) {
      config.pageIndex = parseInt(arg);
    } else {
      config.selectors.push(arg);
    }
    i++;
  }

  return config;
}

// =============================================================================
// 路径工具
// =============================================================================

function findProjectRoot() {
  let currentDir = process.cwd();
  const root = path.parse(currentDir).root;
  
  while (currentDir !== root) {
    const packageJsonPath = path.join(currentDir, 'package.json');
    if (fs.existsSync(packageJsonPath)) {
      return currentDir;
    }
    currentDir = path.dirname(currentDir);
  }
  
  return process.cwd();
}

function resolveOutputDir() {
  const envOutputDir = process.env.DEBUG_OUTPUT_DIR;
  
  if (envOutputDir) {
    if (path.isAbsolute(envOutputDir)) {
      return path.normalize(envOutputDir);
    }
    return path.resolve(process.cwd(), envOutputDir);
  }
  
  return path.resolve(process.cwd(), 'debug-output');
}

// 输出目录
const OUTPUT_DIR = resolveOutputDir();

if (!fs.existsSync(OUTPUT_DIR)) {
  fs.mkdirSync(OUTPUT_DIR, { recursive: true });
}

console.log(`📂 工作目录: ${process.cwd()}`);
console.log(`📁 输出目录: ${OUTPUT_DIR}\n`);

// =============================================================================
// 样式分析函数
// =============================================================================

async function getElementStyles(page, selector) {
  return await page.evaluate((sel) => {
    const elements = document.querySelectorAll(sel);
    return Array.from(elements).slice(0, 10).map((el, idx) => {
      const computed = window.getComputedStyle(el);
      const rect = el.getBoundingClientRect();
      
      return {
        index: idx,
        tagName: el.tagName,
        className: el.className,
        id: el.id,
        text: el.innerText?.substring(0, 100),
        position: {
          x: Math.round(rect.x),
          y: Math.round(rect.y),
          width: Math.round(rect.width),
          height: Math.round(rect.height),
        },
        styles: {
          color: computed.color,
          backgroundColor: computed.backgroundColor,
          borderColor: computed.borderColor,
          fontFamily: computed.fontFamily,
          fontSize: computed.fontSize,
          fontWeight: computed.fontWeight,
          lineHeight: computed.lineHeight,
          textAlign: computed.textAlign,
          display: computed.display,
          position: computed.position,
          flexDirection: computed.flexDirection,
          justifyContent: computed.justifyContent,
          alignItems: computed.alignItems,
          padding: computed.padding,
          margin: computed.margin,
          gap: computed.gap,
          borderRadius: computed.borderRadius,
          borderWidth: computed.borderWidth,
          borderStyle: computed.borderStyle,
          boxShadow: computed.boxShadow,
          opacity: computed.opacity,
          overflow: computed.overflow,
          cursor: computed.cursor,
        }
      };
    });
  }, selector);
}

async function getPageStyleOverview(page) {
  return await page.evaluate(() => {
    const body = document.body;
    const computed = window.getComputedStyle(body);
    
    const getAllColors = (el) => {
      const colors = new Set();
      const addColor = (color) => {
        if (color && color !== 'rgba(0, 0, 0, 0)' && color !== 'transparent') {
          colors.add(color);
        }
      };
      
      const walk = (node) => {
        if (node.nodeType === 1) {
          const style = window.getComputedStyle(node);
          addColor(style.color);
          addColor(style.backgroundColor);
          addColor(style.borderColor);
          for (const child of node.children) {
            walk(child);
          }
        }
      };
      walk(el);
      return Array.from(colors).slice(0, 20);
    };
    
    const getAllFonts = (el) => {
      const fonts = new Set();
      const walk = (node) => {
        if (node.nodeType === 1) {
          const style = window.getComputedStyle(node);
          fonts.add(style.fontFamily);
          for (const child of node.children) {
            walk(child);
          }
        }
      };
      walk(el);
      return Array.from(fonts).slice(0, 10);
    };
    
    return {
      viewport: {
        width: window.innerWidth,
        height: window.innerHeight,
        scrollHeight: document.documentElement.scrollHeight,
      },
      bodyStyles: {
        backgroundColor: computed.backgroundColor,
        color: computed.color,
        fontFamily: computed.fontFamily,
        fontSize: computed.fontSize,
      },
      usedColors: getAllColors(body),
      usedFonts: getAllFonts(body),
    };
  });
}

async function getDOMTreeWithStyles(page, maxDepth = 4) {
  return await page.evaluate((depth) => {
    const processNode = (el, currentDepth) => {
      if (currentDepth > depth || !el) return null;
      
      const computed = window.getComputedStyle(el);
      const rect = el.getBoundingClientRect();
      
      if (rect.width === 0 && rect.height === 0) return null;
      
      const children = [];
      for (const child of el.children) {
        const processed = processNode(child, currentDepth + 1);
        if (processed) children.push(processed);
      }
      
      return {
        tag: el.tagName.toLowerCase(),
        id: el.id || undefined,
        class: el.className || undefined,
        text: el.childNodes.length === 1 && el.childNodes[0].nodeType === 3 
          ? el.textContent?.trim().substring(0, 50) 
          : undefined,
        rect: {
          x: Math.round(rect.x),
          y: Math.round(rect.y),
          w: Math.round(rect.width),
          h: Math.round(rect.height),
        },
        style: {
          bg: computed.backgroundColor,
          color: computed.color,
          display: computed.display,
          fontSize: computed.fontSize,
        },
        children: children.length > 0 ? children : undefined,
      };
    };
    
    return processNode(document.body, 0);
  }, maxDepth);
}

// =============================================================================
// 网络请求捕获
// =============================================================================

function setupNetworkCapture(page) {
  const requests = [];

  page.on('request', (request) => {
    requests.push({
      timestamp: new Date().toISOString(),
      method: request.method(),
      url: request.url(),
      resourceType: request.resourceType(),
      headers: request.headers(),
      postData: request.postData() || undefined,
    });
  });

  page.on('response', async (response) => {
    const url = response.url();
    const entry = requests.find(r => r.url === url && !r.status);
    if (entry) {
      entry.status = response.status();
      entry.statusText = response.statusText();
      entry.responseHeaders = response.headers();
      try {
        const timing = response.request().timing();
        if (timing) {
          entry.timing = timing;
        }
      } catch (_) {
        // timing may not be available
      }
    }
  });

  page.on('requestfailed', (request) => {
    const url = request.url();
    const entry = requests.find(r => r.url === url && !r.status);
    if (entry) {
      entry.failed = true;
      entry.failureText = request.failure()?.errorText;
    }
  });

  return requests;
}

// =============================================================================
// Console 日志捕获
// =============================================================================

function setupConsoleCapture(page) {
  const logs = [];

  page.on('console', (msg) => {
    logs.push({
      timestamp: new Date().toISOString(),
      type: msg.type(),
      text: msg.text(),
      location: msg.location(),
    });
  });

  page.on('pageerror', (error) => {
    logs.push({
      timestamp: new Date().toISOString(),
      type: 'error',
      text: error.message,
      stack: error.stack,
    });
  });

  return logs;
}

// =============================================================================
// 性能指标采集
// =============================================================================

async function getPerformanceMetrics(page) {
  const metrics = await page.evaluate(() => {
    const perf = window.performance;
    const navigation = perf.getEntriesByType('navigation')[0];
    const paint = perf.getEntriesByType('paint');
    
    // Web Vitals approximation
    const lcpEntries = perf.getEntriesByType('largest-contentful-paint');
    const layoutShiftEntries = perf.getEntriesByType('layout-shift');
    
    // Calculate CLS
    let cls = 0;
    if (layoutShiftEntries.length > 0) {
      for (const entry of layoutShiftEntries) {
        if (!entry.hadRecentInput) {
          cls += entry.value;
        }
      }
    }
    
    // Navigation timing
    const timing = {};
    if (navigation) {
      timing.dnsLookup = Math.round(navigation.domainLookupEnd - navigation.domainLookupStart);
      timing.tcpConnect = Math.round(navigation.connectEnd - navigation.connectStart);
      timing.ttfb = Math.round(navigation.responseStart - navigation.requestStart);
      timing.contentDownload = Math.round(navigation.responseEnd - navigation.responseStart);
      timing.domInteractive = Math.round(navigation.domInteractive - navigation.startTime);
      timing.domContentLoaded = Math.round(navigation.domContentLoadedEventEnd - navigation.startTime);
      timing.loadComplete = Math.round(navigation.loadEventEnd - navigation.startTime);
      timing.transferSize = navigation.transferSize;
      timing.encodedBodySize = navigation.encodedBodySize;
      timing.decodedBodySize = navigation.decodedBodySize;
    }
    
    // Paint timing
    const paintMetrics = {};
    for (const entry of paint) {
      paintMetrics[entry.name] = Math.round(entry.startTime);
    }
    
    // LCP
    let lcp = null;
    if (lcpEntries.length > 0) {
      const lastLcp = lcpEntries[lcpEntries.length - 1];
      lcp = {
        time: Math.round(lastLcp.startTime),
        size: lastLcp.size,
        element: lastLcp.element?.tagName,
      };
    }
    
    // Resource summary
    const resources = perf.getEntriesByType('resource');
    const resourceSummary = {};
    for (const r of resources) {
      const type = r.initiatorType || 'other';
      if (!resourceSummary[type]) {
        resourceSummary[type] = { count: 0, totalSize: 0, totalDuration: 0 };
      }
      resourceSummary[type].count++;
      resourceSummary[type].totalSize += r.transferSize || 0;
      resourceSummary[type].totalDuration += r.duration || 0;
    }
    
    // Format resource summary
    for (const type in resourceSummary) {
      resourceSummary[type].avgDuration = Math.round(resourceSummary[type].totalDuration / resourceSummary[type].count);
      resourceSummary[type].totalSize = Math.round(resourceSummary[type].totalSize);
      resourceSummary[type].totalDuration = Math.round(resourceSummary[type].totalDuration);
    }
    
    // Memory (Chrome only)
    let memory = null;
    if (perf.memory) {
      memory = {
        usedJSHeapSize: Math.round(perf.memory.usedJSHeapSize / 1024 / 1024 * 100) / 100,
        totalJSHeapSize: Math.round(perf.memory.totalJSHeapSize / 1024 / 1024 * 100) / 100,
        jsHeapSizeLimit: Math.round(perf.memory.jsHeapSizeLimit / 1024 / 1024 * 100) / 100,
        unit: 'MB',
      };
    }
    
    return {
      navigationTiming: timing,
      paintMetrics,
      lcp,
      cls: Math.round(cls * 1000) / 1000,
      resourceSummary,
      totalResources: resources.length,
      memory,
    };
  });
  
  return metrics;
}

// =============================================================================
// 报告生成
// =============================================================================

function generateStyleReport(overview, domTree, elementStyles, networkRequests, consoleLogs, perfMetrics) {
  let report = `# 📊 Playwright Pro - 页面分析报告\n\n`;
  report += `生成时间: ${new Date().toLocaleString()}\n\n`;
  
  // 视口信息
  report += `## 🖥️ 视口信息\n`;
  report += `- 宽度: ${overview.viewport.width}px\n`;
  report += `- 高度: ${overview.viewport.height}px\n`;
  report += `- 滚动高度: ${overview.viewport.scrollHeight}px\n\n`;
  
  // 性能指标
  if (perfMetrics) {
    report += `## ⚡ 性能指标\n\n`;
    if (perfMetrics.navigationTiming.ttfb) {
      report += `| 指标 | 值 |\n|------|----|\n`;
      report += `| TTFB (首字节时间) | ${perfMetrics.navigationTiming.ttfb}ms |\n`;
      if (perfMetrics.paintMetrics['first-paint']) {
        report += `| FP (首次绘制) | ${perfMetrics.paintMetrics['first-paint']}ms |\n`;
      }
      if (perfMetrics.paintMetrics['first-contentful-paint']) {
        report += `| FCP (首次内容绘制) | ${perfMetrics.paintMetrics['first-contentful-paint']}ms |\n`;
      }
      if (perfMetrics.lcp) {
        report += `| LCP (最大内容绘制) | ${perfMetrics.lcp.time}ms |\n`;
      }
      report += `| CLS (累计布局偏移) | ${perfMetrics.cls} |\n`;
      report += `| DOM Interactive | ${perfMetrics.navigationTiming.domInteractive}ms |\n`;
      report += `| Load Complete | ${perfMetrics.navigationTiming.loadComplete}ms |\n`;
      report += `\n`;
    }
    
    if (perfMetrics.memory) {
      report += `### 内存使用\n`;
      report += `- JS 堆使用: ${perfMetrics.memory.usedJSHeapSize} MB\n`;
      report += `- JS 堆总量: ${perfMetrics.memory.totalJSHeapSize} MB\n\n`;
    }
    
    if (perfMetrics.resourceSummary && Object.keys(perfMetrics.resourceSummary).length > 0) {
      report += `### 资源加载概要\n\n`;
      report += `| 类型 | 数量 | 总大小 | 平均耗时 |\n|------|------|--------|----------|\n`;
      for (const [type, data] of Object.entries(perfMetrics.resourceSummary)) {
        const sizeKB = Math.round(data.totalSize / 1024);
        report += `| ${type} | ${data.count} | ${sizeKB} KB | ${data.avgDuration}ms |\n`;
      }
      report += `\n`;
    }
  }
  
  // 颜色方案
  report += `## 🎨 使用的颜色\n`;
  overview.usedColors.forEach((color, i) => {
    report += `- ${i + 1}. \`${color}\`\n`;
  });
  report += `\n`;
  
  // 字体
  report += `## 🔤 使用的字体\n`;
  overview.usedFonts.forEach((font, i) => {
    report += `- ${i + 1}. \`${font}\`\n`;
  });
  report += `\n`;
  
  // Body 基础样式
  report += `## 📝 页面基础样式\n`;
  report += `- 背景色: \`${overview.bodyStyles.backgroundColor}\`\n`;
  report += `- 文字颜色: \`${overview.bodyStyles.color}\`\n`;
  report += `- 字体: \`${overview.bodyStyles.fontFamily}\`\n`;
  report += `- 字号: \`${overview.bodyStyles.fontSize}\`\n\n`;
  
  // 关键元素样式
  if (elementStyles && Object.keys(elementStyles).length > 0) {
    report += `## 🎯 关键元素样式\n\n`;
    for (const [selector, elements] of Object.entries(elementStyles)) {
      report += `### 选择器: \`${selector}\`\n`;
      elements.forEach((el, i) => {
        report += `\n**元素 ${i + 1}** (${el.tagName})\n`;
        if (el.text) report += `- 文本: "${el.text.substring(0, 30)}..."\n`;
        report += `- 位置: (${el.position.x}, ${el.position.y})\n`;
        report += `- 尺寸: ${el.position.width} x ${el.position.height}px\n`;
        report += `- 背景色: \`${el.styles.backgroundColor}\`\n`;
        report += `- 文字颜色: \`${el.styles.color}\`\n`;
        report += `- 字号: \`${el.styles.fontSize}\`\n`;
        report += `- 边框圆角: \`${el.styles.borderRadius}\`\n`;
        if (el.styles.boxShadow !== 'none') {
          report += `- 阴影: \`${el.styles.boxShadow}\`\n`;
        }
      });
      report += `\n`;
    }
  }
  
  // 网络请求摘要
  if (networkRequests && networkRequests.length > 0) {
    report += `## 🌐 网络请求摘要\n\n`;
    report += `共 ${networkRequests.length} 个请求\n\n`;
    
    // 按资源类型统计
    const byType = {};
    for (const req of networkRequests) {
      const type = req.resourceType || 'other';
      if (!byType[type]) byType[type] = { count: 0, failed: 0 };
      byType[type].count++;
      if (req.failed) byType[type].failed++;
    }
    
    report += `| 类型 | 数量 | 失败 |\n|------|------|------|\n`;
    for (const [type, data] of Object.entries(byType)) {
      report += `| ${type} | ${data.count} | ${data.failed} |\n`;
    }
    report += `\n`;
    
    // 失败的请求
    const failedReqs = networkRequests.filter(r => r.failed);
    if (failedReqs.length > 0) {
      report += `### ❌ 失败的请求\n\n`;
      for (const req of failedReqs) {
        report += `- \`${req.method} ${req.url.substring(0, 80)}\` — ${req.failureText}\n`;
      }
      report += `\n`;
    }
  }
  
  // Console 错误摘要
  if (consoleLogs && consoleLogs.length > 0) {
    const errors = consoleLogs.filter(l => l.type === 'error');
    const warnings = consoleLogs.filter(l => l.type === 'warning');
    
    if (errors.length > 0 || warnings.length > 0) {
      report += `## 🖥️ Console 问题\n\n`;
      report += `- 错误: ${errors.length} 条\n`;
      report += `- 警告: ${warnings.length} 条\n\n`;
      
      if (errors.length > 0) {
        report += `### 错误详情\n\n`;
        for (const err of errors.slice(0, 10)) {
          report += `- \`${err.text.substring(0, 200)}\`\n`;
        }
        report += `\n`;
      }
    }
  }
  
  return report;
}

function formatDOMTree(node, indent = 0) {
  if (!node) return '';
  
  const spaces = '  '.repeat(indent);
  let result = `${spaces}<${node.tag}`;
  
  if (node.id) result += ` id="${node.id}"`;
  if (node.class) result += ` class="${String(node.class).substring(0, 50)}"`;
  
  result += ` [${node.rect.w}x${node.rect.h}]`;
  result += ` bg:${node.style.bg} color:${node.style.color}`;
  
  if (node.text) {
    result += `>${node.text}</${node.tag}>`;
  } else if (node.children && node.children.length > 0) {
    result += `>\n`;
    for (const child of node.children) {
      result += formatDOMTree(child, indent + 1);
    }
    result += `${spaces}</${node.tag}>`;
  } else {
    result += ` />`;
  }
  
  return result + '\n';
}

// =============================================================================
// 标签页选择
// =============================================================================

function findPageByUrl(pages, keyword) {
  const lowerKeyword = keyword.toLowerCase();
  
  // 精确匹配（URL 包含关键字）
  const exactMatches = pages.filter(p => 
    p.url().toLowerCase().includes(lowerKeyword)
  );
  
  if (exactMatches.length === 1) {
    return { page: exactMatches[0], index: pages.indexOf(exactMatches[0]) };
  }
  
  if (exactMatches.length > 1) {
    console.log(`\n🔍 匹配到 ${exactMatches.length} 个标签页：`);
    exactMatches.forEach((p, i) => {
      const idx = pages.indexOf(p);
      console.log(`   [${idx}] ${p.url().substring(0, 80)}`);
    });
    console.log(`\n   使用第一个匹配项 [${pages.indexOf(exactMatches[0])}]`);
    return { page: exactMatches[0], index: pages.indexOf(exactMatches[0]) };
  }
  
  // 尝试标题匹配
  // Note: title() is async, handled in caller
  return null;
}

async function findPageByUrlOrTitle(pages, keyword) {
  // 先尝试 URL 匹配
  const urlMatch = findPageByUrl(pages, keyword);
  if (urlMatch) return urlMatch;
  
  // 再尝试标题匹配
  const lowerKeyword = keyword.toLowerCase();
  for (let i = 0; i < pages.length; i++) {
    try {
      const title = await pages[i].title();
      if (title.toLowerCase().includes(lowerKeyword)) {
        return { page: pages[i], index: i };
      }
    } catch (_) {
      // 某些页面可能无法获取标题
    }
  }
  
  return null;
}

// =============================================================================
// 主程序
// =============================================================================

(async () => {
  const config = parseArgs();
  const cdpPort = process.env.CDP_PORT || 9222;

  console.log(`🔌 Connecting to browser on port ${cdpPort}...`);

  try {
    const browser = await chromium.connectOverCDP(`http://127.0.0.1:${cdpPort}`);
    const defaultContext = browser.contexts()[0];
    const pages = defaultContext.pages();

    console.log('✅ Connected to existing browser session!');
    console.log(`📑 共 ${pages.length} 个标签页\n`);
    
    // 列出所有页面
    for (let i = 0; i < pages.length; i++) {
      let title = '';
      try { title = await pages[i].title(); } catch (_) {}
      const marker = '  ';
      console.log(`${marker} [${i}] ${pages[i].url().substring(0, 60)}${title ? ` — ${title.substring(0, 30)}` : ''}`);
    }
    console.log('');
    
    // 选择目标页面
    let targetPage;
    let targetIndex;
    
    if (config.urlKeyword) {
      const match = await findPageByUrlOrTitle(pages, config.urlKeyword);
      if (!match) {
        console.error(`❌ 未找到匹配 "${config.urlKeyword}" 的标签页`);
        console.error(`   请检查 URL 或标题关键字`);
        await browser.close();
        return;
      }
      targetPage = match.page;
      targetIndex = match.index;
      console.log(`🔍 通过关键字 "${config.urlKeyword}" 匹配到标签页 [${targetIndex}]`);
    } else {
      targetIndex = config.pageIndex;
      targetPage = pages[targetIndex];
      if (!targetPage) {
        console.error(`❌ 页面索引 ${targetIndex} 不存在`);
        await browser.close();
        return;
      }
    }
    
    const pageUrl = targetPage.url();
    console.log(`🎯 分析页面: ${pageUrl}\n`);
    
    // ===== 设置网络和 Console 捕获 =====
    let networkRequests = [];
    let consoleLogs = [];
    
    if (config.captureNetwork) {
      console.log('🌐 开始捕获网络请求...');
      networkRequests = setupNetworkCapture(targetPage);
    }
    
    if (config.captureConsole) {
      console.log('🖥️  开始捕获 Console 日志...');
      consoleLogs = setupConsoleCapture(targetPage);
    }
    
    // 如果需要捕获网络请求，刷新页面并等待
    if (config.captureNetwork) {
      console.log(`   ⏳ 刷新页面以捕获完整请求（等待 ${config.networkWait}s）...\n`);
      try {
        await targetPage.reload({ waitUntil: 'networkidle', timeout: config.networkWait * 1000 + 10000 });
      } catch (_) {
        // 超时也没关系，继续分析
      }
      // 额外等待
      await new Promise(resolve => setTimeout(resolve, Math.min(config.networkWait * 1000, 5000)));
    }
    
    // 1. 截图
    console.log('📸 正在截图...');
    const screenshotPath = path.join(OUTPUT_DIR, 'screenshot.png');
    const fullPageScreenshotPath = path.join(OUTPUT_DIR, 'screenshot-full.png');
    
    try {
      await targetPage.screenshot({ path: screenshotPath });
      console.log(`   ✅ 视口截图: ${screenshotPath}`);
      
      await targetPage.screenshot({ path: fullPageScreenshotPath, fullPage: true });
      console.log(`   ✅ 全页截图: ${fullPageScreenshotPath}`);
    } catch (e) {
      console.log(`   ⚠️ 截图失败: ${e.message}`);
    }
    
    // 2. 获取页面样式概览
    console.log('\n🎨 正在分析页面样式...');
    const styleOverview = await getPageStyleOverview(targetPage);
    console.log(`   ✅ 视口: ${styleOverview.viewport.width}x${styleOverview.viewport.height}`);
    console.log(`   ✅ 发现 ${styleOverview.usedColors.length} 种颜色`);
    console.log(`   ✅ 发现 ${styleOverview.usedFonts.length} 种字体`);
    
    // 3. 获取 DOM 树
    console.log('\n🌲 正在获取 DOM 结构...');
    const domTree = await getDOMTreeWithStyles(targetPage, 4);
    
    // 4. 获取关键元素样式
    console.log('\n🔍 正在分析关键元素...');
    const defaultSelectors = [
      'button',
      'a',
      'input',
      'h1, h2, h3',
      '.sidebar, [class*="sidebar"]',
      '.header, [class*="header"]',
      '.card, [class*="card"]',
      '.btn, [class*="btn"]',
    ];
    
    const targetSelectors = config.selectors.length > 0 ? config.selectors : defaultSelectors;
    const elementStyles = {};
    
    for (const selector of targetSelectors) {
      try {
        const styles = await getElementStyles(targetPage, selector);
        if (styles.length > 0) {
          elementStyles[selector] = styles;
          console.log(`   ✅ ${selector}: ${styles.length} 个元素`);
        }
      } catch (e) {
        // 忽略无效选择器
      }
    }
    
    // 5. 性能指标
    let perfMetrics = null;
    if (config.capturePerf) {
      console.log('\n⚡ 正在采集性能指标...');
      try {
        perfMetrics = await getPerformanceMetrics(targetPage);
        if (perfMetrics.navigationTiming.ttfb) {
          console.log(`   ✅ TTFB: ${perfMetrics.navigationTiming.ttfb}ms`);
        }
        if (perfMetrics.paintMetrics['first-contentful-paint']) {
          console.log(`   ✅ FCP: ${perfMetrics.paintMetrics['first-contentful-paint']}ms`);
        }
        if (perfMetrics.lcp) {
          console.log(`   ✅ LCP: ${perfMetrics.lcp.time}ms`);
        }
        console.log(`   ✅ CLS: ${perfMetrics.cls}`);
        if (perfMetrics.memory) {
          console.log(`   ✅ 内存: ${perfMetrics.memory.usedJSHeapSize} MB`);
        }
        console.log(`   ✅ 资源数: ${perfMetrics.totalResources}`);
      } catch (e) {
        console.log(`   ⚠️ 性能指标采集失败: ${e.message}`);
      }
    }
    
    // 6. 生成报告
    console.log('\n📝 正在生成报告...');
    
    // 样式报告（包含性能、网络、Console 摘要）
    const styleReport = generateStyleReport(styleOverview, domTree, elementStyles, networkRequests, consoleLogs, perfMetrics);
    const reportPath = path.join(OUTPUT_DIR, 'style-report.md');
    fs.writeFileSync(reportPath, styleReport);
    console.log(`   ✅ 分析报告: ${reportPath}`);
    
    // DOM 树
    const domTreeText = formatDOMTree(domTree);
    const domTreePath = path.join(OUTPUT_DIR, 'dom-tree.txt');
    fs.writeFileSync(domTreePath, domTreeText);
    console.log(`   ✅ DOM 结构: ${domTreePath}`);
    
    // JSON 数据
    const jsonData = {
      url: pageUrl,
      timestamp: new Date().toISOString(),
      overview: styleOverview,
      domTree: domTree,
      elementStyles: elementStyles,
      performanceMetrics: perfMetrics,
    };
    const jsonPath = path.join(OUTPUT_DIR, 'page-data.json');
    fs.writeFileSync(jsonPath, JSON.stringify(jsonData, null, 2));
    console.log(`   ✅ JSON 数据: ${jsonPath}`);
    
    // 无障碍快照
    console.log('\n♿ 正在获取无障碍快照...');
    try {
      const snapshot = await targetPage.accessibility.snapshot();
      const snapshotPath = path.join(OUTPUT_DIR, 'accessibility-snapshot.json');
      fs.writeFileSync(snapshotPath, JSON.stringify(snapshot, null, 2));
      console.log(`   ✅ 无障碍快照: ${snapshotPath}`);
    } catch (e) {
      console.log(`   ⚠️ 无障碍快照失败: ${e.message}`);
    }
    
    // 网络请求日志
    if (config.captureNetwork && networkRequests.length > 0) {
      const networkPath = path.join(OUTPUT_DIR, 'network-requests.json');
      fs.writeFileSync(networkPath, JSON.stringify(networkRequests, null, 2));
      console.log(`   ✅ 网络请求 (${networkRequests.length} 条): ${networkPath}`);
    }
    
    // Console 日志
    if (config.captureConsole && consoleLogs.length > 0) {
      const consolePath = path.join(OUTPUT_DIR, 'console-logs.json');
      fs.writeFileSync(consolePath, JSON.stringify(consoleLogs, null, 2));
      console.log(`   ✅ Console 日志 (${consoleLogs.length} 条): ${consolePath}`);
    }
    
    // 性能指标
    if (perfMetrics) {
      const perfPath = path.join(OUTPUT_DIR, 'performance-metrics.json');
      fs.writeFileSync(perfPath, JSON.stringify(perfMetrics, null, 2));
      console.log(`   ✅ 性能指标: ${perfPath}`);
    }
    
    // 打印简要摘要
    console.log('\n' + '═'.repeat(60));
    console.log('📊 分析完成！输出文件:');
    console.log('═'.repeat(60));
    
    const files = [
      '📸 screenshot.png        - 视口截图',
      '📸 screenshot-full.png   - 全页截图',
      '📄 style-report.md       - 综合分析报告',
      '🌲 dom-tree.txt          - DOM 结构树',
      '📊 page-data.json        - 完整数据 (JSON)',
      '♿ accessibility-snapshot.json - 无障碍快照',
    ];
    
    if (config.captureNetwork && networkRequests.length > 0) {
      files.push(`🌐 network-requests.json - 网络请求 (${networkRequests.length} 条)`);
    }
    if (config.captureConsole && consoleLogs.length > 0) {
      files.push(`🖥️  console-logs.json     - Console 日志 (${consoleLogs.length} 条)`);
    }
    if (perfMetrics) {
      files.push('⚡ performance-metrics.json - 性能指标');
    }
    
    console.log(`\n📁 ${OUTPUT_DIR}/`);
    files.forEach((f, i) => {
      const prefix = i === files.length - 1 ? '└──' : '├──';
      console.log(`${prefix} ${f}`);
    });
    
    console.log(`\n💡 提示: 将 style-report.md 的内容发送给 AI，它就能理解页面的样式和性能了！\n`);
    
    await browser.close();
    
  } catch (error) {
    console.error('❌ Failed to connect:', error.message);
    console.error('   Make sure browser is running with --remote-debugging-port');
    console.error('\n💡 启动步骤:');
    console.error('   1. 运行 launch-chrome.sh 启动调试版浏览器');
    console.error('   2. 等待浏览器启动完成');
    console.error('   3. 再次运行此脚本');
    console.error('\n   也可以使用 --url <关键字> 按 URL 匹配标签页');
  }
})();
