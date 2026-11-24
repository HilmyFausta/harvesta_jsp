<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>
<!DOCTYPE html>
<html lang="en" class="h-full">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>${pageContext.errorData.statusCode != 0 ? pageContext.errorData.statusCode : 'Error'} - Harvesta</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/build/assets/app-C1XXSIRJ.css" />
    <link rel="icon" href="${pageContext.request.contextPath}/favicon.ico" sizes="any">
</head>
<body class="min-h-screen bg-cream text-ink dark:bg-zinc-800 dark:text-white flex items-center justify-center p-6">
    <div class="max-w-md w-full text-center space-y-6">
        <div class="mx-auto flex aspect-square size-16 items-center justify-center rounded-2xl bg-[var(--color-accent)] text-white shadow-lg">
            ${h:icon('leaf')}
        </div>
        <div>
            <h1 class="text-6xl font-bold tracking-tight text-[var(--color-accent)]">
                ${pageContext.errorData.statusCode != 0 ? pageContext.errorData.statusCode : 500}
            </h1>
            <h2 class="mt-4 text-2xl font-semibold tracking-tight text-zinc-900 dark:text-white">
                <c:choose>
                    <c:when test="${pageContext.errorData.statusCode == 404}">Page not found</c:when>
                    <c:when test="${pageContext.errorData.statusCode == 403}">Access denied</c:when>
                    <c:otherwise>Something went wrong</c:otherwise>
                </c:choose>
            </h2>
            <p class="mt-2 text-sm text-zinc-600 dark:text-zinc-400">
                <c:choose>
                    <c:when test="${pageContext.errorData.statusCode == 404}">Sorry, we couldn't find the page you're looking for.</c:when>
                    <c:when test="${pageContext.errorData.statusCode == 403}">You do not have permission to access this resource.</c:when>
                    <c:otherwise>An unexpected error occurred. Please try again or return to the dashboard.</c:otherwise>
                </c:choose>
            </p>
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/dashboard"
               class="inline-flex items-center justify-center px-6 py-2.5 rounded-lg text-sm font-medium bg-[var(--color-accent)] text-white hover:opacity-90 transition-opacity">
                Back to Dashboard
            </a>
        </div>
    </div>
</body>
</html>
