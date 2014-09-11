function PagerUtil () {
    this.createHTML = function(pageCount,currentPageNumber,itemsPerPage,controllerName) {
        html = ""

        // Rule 1
        if (currentPageNumber == 1) {
            html += '<li class="disabled"><a>&laquo;</a></li>'
        } else {
            html += '<li><a href="javascript:' + controllerName + '.listItems(' + ((currentPageNumber - 2) * itemsPerPage) + ',' + itemsPerPage + ')">&laquo;</a></li>'
        }

        firstPageNumber = 1
        // Rules 2 & 3
        if (currentPageNumber > 3 && pageCount > 5) {
            if ((pageCount - currentPageNumber) > 2) {
                firstPageNumber = currentPageNumber - 2
            } else {
                firstPageNumber = pageCount - 4
            }
        }

        for(i = 0; i < pageCount; i++) {
            pageNumber = i + 1
            pageOffset = i * itemsPerPage

            if(pageNumber >= firstPageNumber && pageNumber <= (firstPageNumber + 4)) {
                if(pageNumber == currentPageNumber) {
                    html += '<li class="active"><a href="javascript:' + controllerName +'.listItems(' + pageOffset + ',' + itemsPerPage + ')">' + pageNumber + '</a></li>'
                }
                else {
                    html += '<li><a href="javascript:' + controllerName + '.listItems(' + pageOffset + ',' + itemsPerPage + ')">' + pageNumber + '</a></li>'
                }
            }
        }
        // Rule 4
        if (currentPageNumber == pageCount) {
            html += '<li class="disabled"><a>&raquo;</a></li>'
        } else {
            html += '<li><a href="javascript:' + controllerName + '.listItems(' + (currentPageNumber*itemsPerPage) + ',' + itemsPerPage + ')">&raquo;</a></li>'
        }
        return html;
    }
}
