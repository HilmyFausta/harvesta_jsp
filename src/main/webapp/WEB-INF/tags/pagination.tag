<%@ tag pageEncoding="UTF-8" trimDirectiveWhitespaces="true" %>
<%@ attribute name="currentPage" type="java.lang.Integer" required="true" %>
<%@ attribute name="totalPages" type="java.lang.Integer" required="true" %>
<%@ attribute name="totalCount" type="java.lang.Long" required="true" %>
<%@ attribute name="pageSize" type="java.lang.Integer" required="true" %>
<%@ attribute name="queryString" required="false" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="h" uri="https://harvesta.app/functions" %>

<c:if test="${totalCount > 0}">
    <c:set var="from" value="${(currentPage - 1) * pageSize + 1}" />
    <c:set var="to" value="${currentPage * pageSize > totalCount ? totalCount : currentPage * pageSize}" />
    <c:set var="qs" value="${not empty queryString ? queryString : ''}" />

    <div class="pt-4 flex items-center justify-between border-t border-zinc-200 dark:border-zinc-700 text-sm text-zinc-500 dark:text-zinc-400">
        <div>
            Showing <span class="font-medium text-zinc-800 dark:text-white">${from}</span> to
            <span class="font-medium text-zinc-800 dark:text-white">${to}</span> of
            <span class="font-medium text-zinc-800 dark:text-white">${totalCount}</span> results
        </div>

        <c:if test="${totalPages > 1}">
            <div class="flex items-center gap-1 bg-white border border-zinc-200 rounded-lg p-0.5 dark:bg-white/10 dark:border-white/10">
                <!-- Previous Button -->
                <c:choose>
                    <c:when test="${currentPage > 1}">
                        <a href="?page=${currentPage - 1}${qs}" class="flex items-center justify-center size-7 rounded-md text-zinc-500 hover:bg-zinc-100 hover:text-zinc-800 dark:hover:bg-white/20 dark:hover:text-white" aria-label="Previous">
                            <svg class="size-4" viewBox="0 0 16 16" fill="currentColor"><path fill-rule="evenodd" d="M9.78 4.22a.75.75 0 0 1 0 1.06L7.06 8l2.72 2.72a.75.75 0 1 1-1.06 1.06L5.47 8.53a.75.75 0 0 1 0-1.06l3.25-3.25a.75.75 0 0 1 1.06 0Z" clip-rule="evenodd" /></svg>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="flex items-center justify-center size-7 rounded-md text-zinc-300 dark:text-zinc-600 cursor-not-allowed">
                            <svg class="size-4" viewBox="0 0 16 16" fill="currentColor"><path fill-rule="evenodd" d="M9.78 4.22a.75.75 0 0 1 0 1.06L7.06 8l2.72 2.72a.75.75 0 1 1-1.06 1.06L5.47 8.53a.75.75 0 0 1 0-1.06l3.25-3.25a.75.75 0 0 1 1.06 0Z" clip-rule="evenodd" /></svg>
                        </span>
                    </c:otherwise>
                </c:choose>

                <!-- Page numbers -->
                <c:forEach begin="1" end="${totalPages}" var="p">
                    <c:choose>
                        <c:when test="${p == currentPage}">
                            <span class="flex items-center justify-center text-xs h-7 px-2.5 rounded-md font-semibold bg-zinc-100 text-zinc-800 dark:bg-white/20 dark:text-white">${p}</span>
                        </c:when>
                        <c:otherwise>
                            <a href="?page=${p}${qs}" class="flex items-center justify-center text-xs h-7 px-2.5 rounded-md text-zinc-500 font-medium hover:bg-zinc-100 hover:text-zinc-800 dark:text-zinc-400 dark:hover:bg-white/20 dark:hover:text-white">${p}</a>
                        </c:otherwise>
                    </c:choose>
                </c:forEach>

                <!-- Next Button -->
                <c:choose>
                    <c:when test="${currentPage < totalPages}">
                        <a href="?page=${currentPage + 1}${qs}" class="flex items-center justify-center size-7 rounded-md text-zinc-500 hover:bg-zinc-100 hover:text-zinc-800 dark:hover:bg-white/20 dark:hover:text-white" aria-label="Next">
                            <svg class="size-4" viewBox="0 0 16 16" fill="currentColor"><path fill-rule="evenodd" d="M6.22 4.22a.75.75 0 0 1 1.06 0l3.25 3.25a.75.75 0 0 1 0 1.06l-3.25 3.25a.75.75 0 0 1-1.06-1.06L8.94 8 6.22 5.28a.75.75 0 0 1 0-1.06Z" clip-rule="evenodd" /></svg>
                        </a>
                    </c:when>
                    <c:otherwise>
                        <span class="flex items-center justify-center size-7 rounded-md text-zinc-300 dark:text-zinc-600 cursor-not-allowed">
                            <svg class="size-4" viewBox="0 0 16 16" fill="currentColor"><path fill-rule="evenodd" d="M6.22 4.22a.75.75 0 0 1 1.06 0l3.25 3.25a.75.75 0 0 1 0 1.06l-3.25 3.25a.75.75 0 0 1-1.06-1.06L8.94 8 6.22 5.28a.75.75 0 0 1 0-1.06Z" clip-rule="evenodd" /></svg>
                        </span>
                    </c:otherwise>
                </c:choose>
            </div>
        </c:if>
    </div>
</c:if>
