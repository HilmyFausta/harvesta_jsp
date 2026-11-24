<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ attribute name="title" required="true" %>
<%@ attribute name="description" required="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>
<div class="mb-6 flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
    <div>
        <h1 class="font-medium text-zinc-800 dark:text-white text-2xl" data-flux-heading>${h:e(title)}</h1>
        <c:if test="${not empty description}">
            <p class="font-normal text-sm text-zinc-500 dark:text-white/70 mt-1" data-flux-text>${h:e(description)}</p>
        </c:if>
    </div>
    <div class="flex flex-wrap items-center gap-2">
        <jsp:doBody />
    </div>
</div>
