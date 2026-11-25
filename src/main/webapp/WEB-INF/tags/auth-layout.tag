<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ attribute name="title" required="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>${h:e(title)} - HARVESTA</title>

    <link rel="icon" href="${ctx}/favicon.ico" sizes="32x32">
    <link rel="icon" href="${ctx}/favicon.svg" type="image/svg+xml">
    <link rel="apple-touch-icon" href="${ctx}/apple-touch-icon.png">

    <style>
    @font-face {
      font-family: "Inter";
      font-style: normal;
      font-weight: 400;
      font-display: swap;
      src: url("${ctx}/build/assets/inter-400-normal-C38fXH4l.woff2") format("woff2");
    }
    @font-face {
      font-family: "Inter";
      font-style: normal;
      font-weight: 500;
      font-display: swap;
      src: url("${ctx}/build/assets/inter-500-normal-Cerq10X2.woff2") format("woff2");
    }
    @font-face {
      font-family: "Inter";
      font-style: normal;
      font-weight: 600;
      font-display: swap;
      src: url("${ctx}/build/assets/inter-600-normal-LgqL8muc.woff2") format("woff2");
    }
    @font-face {
      font-family: "Inter";
      font-style: normal;
      font-weight: 700;
      font-display: swap;
      src: url("${ctx}/build/assets/inter-700-normal-Yt3aPRUw.woff2") format("woff2");
    }
    :root {
      --font-inter: "Inter", -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      --color-accent: #2F7D4F;
      --color-accent-foreground: #FFFFFF;
      --color-accent-content: #2F7D4F;
    }
    body {
      font-family: var(--font-inter);
    }
    html.dark [class*="text-zinc-900"]:not([class*="dark:text-"]) {
      color: #fafafa;
    }
    html.dark [class*="text-zinc-800"]:not([class*="dark:text-"]) {
      color: #f4f4f5;
    }
    html.dark [class*="text-zinc-700"]:not([class*="dark:text-"]) {
      color: #e4e4e7;
    }
    html.dark [class*="text-zinc-600"]:not([class*="dark:text-"]) {
      color: #d4d4d8;
    }
    html.dark [class*="text-zinc-500"]:not([class*="dark:text-"]) {
      color: #a1a1aa;
    }
    html.dark [class*="hover:bg-zinc-"]:not([class*="dark:hover:bg-"]):hover {
      background-color: rgb(63 63 70 / .65);
    }
    html.dark [class*="hover:bg-white"]:not([class*="dark:hover:bg-"]):hover {
      background-color: rgb(255 255 255 / .08);
    }
    html.dark [class*="hover:bg-red-"]:not([class*="dark:hover:bg-"]):hover {
      background-color: rgb(127 29 29 / .25);
    }
    html.dark [class*="hover:text-zinc-900"]:not([class*="dark:hover:text-"]):hover {
      color: #fafafa;
    }
    html.dark input:not([type="checkbox"]):not([type="radio"]),
    html.dark select,
    html.dark textarea {
      color: #f4f4f5;
      background-color: #27272a;
      border-color: #52525b;
    }
    html.dark select option {
      color: #f4f4f5;
      background-color: #27272a;
    }
    </style>
    <link rel="stylesheet" href="${ctx}/build/assets/app-C1XXSIRJ.css" />
    <script>
        window.Flux = {
            applyAppearance(appearance) {
                if (appearance === 'dark' || (appearance === 'system' && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
                    document.documentElement.classList.add('dark');
                } else {
                    document.documentElement.classList.remove('dark');
                }
            }
        };
        window.Flux.applyAppearance(localStorage.getItem('flux.appearance') || 'light');
    </script>
</head>
<body class="min-h-screen bg-white antialiased dark:bg-linear-to-b dark:from-neutral-950 dark:to-neutral-900">
    <div class="bg-background flex min-h-svh flex-col items-center justify-center gap-6 p-6 md:p-10">
        <div class="flex w-full max-w-sm flex-col gap-2">
            <a href="${ctx}/" class="flex flex-col items-center gap-2 font-medium">
                <span class="flex h-10 w-10 mb-1 items-center justify-center rounded-lg bg-[var(--color-accent)] text-white shadow-md">
                    <svg class="size-6 fill-current" viewBox="0 0 24 24" fill="currentColor" stroke="currentColor" stroke-width="2">
                        <path d="M8 19a4 4 0 0 1-2.24-7.32A3.5 3.5 0 0 1 9 6.03V6a3 3 0 1 1 6 0v.04a3.5 3.5 0 0 1 3.24 5.65A4 4 0 0 1 16 19Z" />
                        <path d="M12 19v3" fill="none" />
                    </svg>
                </span>
                <span class="font-bold text-lg tracking-wide text-zinc-900 dark:text-white">HARVESTA</span>
            </a>
            <div class="flex flex-col gap-6">
                <jsp:doBody />
            </div>
        </div>
    </div>
</body>
</html>
